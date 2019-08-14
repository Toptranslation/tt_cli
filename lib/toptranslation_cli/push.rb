# frozen_string_literal: true

require 'tty-spinner'
require 'tty-progressbar'
require 'pastel'

module ToptranslationCli
  class Push # rubocop:disable Metrics/ClassLength
    using Threaded

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
    end

    def run
      @documents = fetch_documents
      changed = changed_files(local_files)
      upload_files(changed)
    rescue RestClient::Forbidden
      @spinner.error('invalid access token')
      exit 1
    end

    private

      def verbose?
        ToptranslationCli.configuration.verbose
      end

      def changed_files(files)
        @spinner.update(title: 'Checking changed files...')
        @spinner.auto_spin
        changed = files.select do |file|
          translation = translation_for_file(file)
          translation_changed?(translation, file)
        end
        @spinner.success(@pastel.green("found #{changed.count} changed file(s)"))
        changed
      end

      def upload_files(files)
        return if files.empty?

        grouped_files = files.group_by { |file| file[:placeholder_path] }.values

        bar = TTY::ProgressBar.new('Uploading [:bar] :percent [:current/:total]', total: grouped_files.flatten.count)
        bar.render

        grouped_files.each_in_threads(8, true) do |file|
          upload_file(file)
          bar.synchronize { bar.log(file[:path]) }
          bar.advance
        end
      end

      def translation_for_file(file)
        remote_document = find_document_by_path(@documents, file[:placeholder_path])
        find_translation_by_locale(remote_document&.translations || [], file[:locale])
      end

      def mark_unchanged(spinner)
        spinner.instance_variable_set(:@success_mark, @pastel.blue('='))
        spinner.success(@pastel.blue('skipping unchanged file'))
      end

      def fetch_documents
        @spinner.update(title: 'Checking remote documents...')
        @spinner.auto_spin
        documents = project&.documents.to_a
        @spinner.success(@pastel.green("found #{documents.count} document(s)"))
        documents
      end

      def local_files
        @spinner.update(title: 'Checking local translations...')
        @spinner.auto_spin
        files = ToptranslationCli.configuration.files.flat_map do |path_definition|
          project_locales.flat_map { |locale| file_to_upload(path_definition, locale) }
        end
        @spinner.success(@pastel.green("found #{files.count} file(s)"))
        files
      end

      def file_to_upload(path_definition, locale)
        placeholder_path = PlaceholderPath.new(path_definition)
        FileFinder.new(path_definition).files(locale.code).flat_map do |path|
          the_placeholder_path = placeholder_path.for_path(path, locale.code)
          {
            path: path,
            placeholder_path: the_placeholder_path,
            locale: locale, sha1: sha1_checksum(path)
          }
        end
      end

      def upload_file(file)
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
