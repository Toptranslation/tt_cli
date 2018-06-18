# frozen_string_literal: true

module ToptranslationCli
  class Push
    class << self
      def run
        ToptranslationCli.configuration.load

        remote_documents = project&.documents
        multibar = TTY::ProgressBar::Multi.new
        files = files_to_upload
        mutexes = {}

        files.map do |file|
          mutex = mutexes[file[:placeholder_path]] ||= Mutex.new
          bar = multibar.register('checking...', total: 100)

          Thread.new do
            begin
              remote_document = find_document_by_path(remote_documents, file[:placeholder_path])
              translation = find_translation_by_locale(remote_document&.translations || [], file[:locale])

              unless translation_changed?(translation, file[:path])
                format_bar!(bar, file, :skipping)
                Thread.current.exit
                next
              end

              bar.update(total: file.size)
              format_bar!(bar, file, :uploading)

              mutex.synchronize do
                upload(file) do |upload_size|
                  bar.advance(upload_size)
                end
              end
            rescue StandardError => e
              file[:error] = e
              format_bar!(bar, file, :error)
            end
          end
        end.map(&:join)
      end

      private

      def format_bar!(bar, file, state)
        format = case state
                 when :skipping then "#{file[:path]}: Skipping unchanged file"
                 when :error then "#{file[:path]}: #{state} Error: #{file[:error].inspect}"
                 when :uploading then "#{file[:path]}: [:bar] :percent"
                 end
        bar.instance_variable_set(:@format, format)
        bar.render
      end

      def translation_changed?(translation, path)
        translation.nil? || translation.sha1 != sha1_checksum(path)
      end

      def sha1_checksum(path)
        Digest::SHA1.file(path).hexdigest
      end

      def find_document_by_path(documents, path_with_placeholder)
        documents.detect { |document| document.path == path_with_placeholder }
      end

      def find_translation_by_locale(translations, locale)
        translations.detect do |translation|
          translation.locale.code == locale.code
        end
      end

      def project_locales
        @project_locales ||= project.locales
      end

      def project
        @project ||= ToptranslationCli.connection.projects.find(ToptranslationCli.configuration.project_identifier)
      end

      def files_to_upload
        mutexes = {}
        ToptranslationCli.configuration.files.flat_map do |path_definition|
          placeholder_path = PlaceholderPath.new(path_definition)
          project_locales.flat_map do |locale|
            FileFinder.new(path_definition).files(locale.code).flat_map do |path|
              the_placeholder_path = placeholder_path.for_path(path, locale.code)
              mutexes[the_placeholder_path] ||= Mutex.new
              file = {
                path: path,
                placeholder_path: the_placeholder_path,
                locale: locale,
                mutex: mutexes[:placeholder_path]
              }
              file
            end
          end
        end
      end

      def upload(file, &block)
        project.upload_document(
          file[:path],
          file[:locale].code,
          path: file[:placeholder_path],
          name: File.basename(file[:path]),
          &block
        )
      end
    end
  end
end
