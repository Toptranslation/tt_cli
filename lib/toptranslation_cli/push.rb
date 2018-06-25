# frozen_string_literal: true

require 'tty-spinner'
require 'pastel'

module ToptranslationCli
  class Push
    class << self
      def run
        new.run
      end
    end

    def initialize
      ToptranslationCli.configuration.load

      @pastel = Pastel.new
      @spinner_settings = { success_mark: @pastel.green('+'), error_mark: @pastel.red('-') }
      @spinner = TTY::Spinner.new("[#{@pastel.yellow(':spinner')}] :title", @spinner_settings)
      @upload_spinners = TTY::Spinner::Multi.new(
        "[#{@pastel.yellow(':spinner')}] Uploading translations...",
        @spinner_settings
      )
    end

    def run
      @documents = fetch_documents
      upload_files(files_to_upload)
    rescue RestClient::Forbidden
      @spinner.error('invalid access token')
      exit 1
    end

    private

      def upload_files(files)
        files.each do |file|
          upload_proc = method(:upload_file).curry[file]
          @upload_spinners.register("[#{@pastel.yellow(':spinner')}] #{file[:path]}", &upload_proc)
        end
        @upload_spinners.auto_spin
      end

      def upload_file(file, spinner)
        remote_document = find_document_by_path(@documents, file[:placeholder_path])
        translation = find_translation_by_locale(remote_document&.translations || [], file[:locale])

        unless translation_changed?(translation, file)
          spinner.instance_variable_set(:@success_mark, @pastel.blue('='))
          return spinner.success(@pastel.blue('skipping unchanged file'))
        end

        file[:mutex].synchronize do
          do_upload(file)
        end

        spinner.success(@pastel.green('done'))
      rescue StandardError => e
        spinner.error(@pastel.red("error: #{e.message}"))
      end

      def fetch_documents
        @spinner.update(title: 'Fetching remote documents...')
        @spinner.auto_spin
        documents = project&.documents.to_a
        @spinner.success(@pastel.green("found #{documents.count} document(s)"))
        documents
      end

      def files_to_upload
        @spinner.update(title: 'Finding local translations...')
        @spinner.auto_spin
        mutexes = {}
        files = ToptranslationCli.configuration.files.flat_map do |path_definition|
          placeholder_path = PlaceholderPath.new(path_definition)
          project_locales.flat_map do |locale|
            FileFinder.new(path_definition).files(locale.code).flat_map do |path|
              the_placeholder_path = placeholder_path.for_path(path, locale.code)
              mutex = mutexes[the_placeholder_path] ||= Mutex.new
              {
                path: path,
                placeholder_path: the_placeholder_path,
                locale: locale,
                mutex: mutex,
                sha1: sha1_checksum(path)
              }
            end
          end
        end
        @spinner.success(@pastel.green("found #{files.count} file(s)"))
        files
      end

      def do_upload(file)
        project.upload_document(
          file[:path],
          file[:locale].code,
          path: file[:placeholder_path],
          name: File.basename(file[:path])
        )
      end

      def translation_changed?(translation, file)
        translation.nil? || translation.sha1 != file[:sha1]
      end

      def sha1_checksum(path)
        Digest::SHA1.file(path).hexdigest
      end

      def find_document_by_path(documents, path_with_placeholder)
        documents.detect { |document| document.path == path_with_placeholder }
      end

      def find_translation_by_locale(translations, locale)
        translations.detect { |translation| translation.locale.code == locale.code }
      end

      def project_locales
        @project_locales ||= project.locales
      end

      def project
        @project ||= ToptranslationCli.connection.projects.find(ToptranslationCli.configuration.project_identifier)
      end
  end
end
