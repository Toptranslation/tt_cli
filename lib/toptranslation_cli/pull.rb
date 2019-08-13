# frozen_string_literal: true

require 'fileutils'
require 'tty-spinner'
require 'pastel'

module ToptranslationCli
  class Pull
    def self.run
      new.run
    end

    def initialize
      ToptranslationCli.configuration.load

      @pastel = Pastel.new
      @spinner_settings = { success_mark: @pastel.green('+'), error_mark: @pastel.red('-') }
      @spinner = TTY::Spinner.new("[#{@pastel.yellow(':spinner')}] :title", @spinner_settings)
      @download_spinners = TTY::Spinner::Multi.new(
        "[#{@pastel.yellow(':spinner')}] Downloading translations...",
        @spinner_settings
      )
    end

    def run
      @files = files_to_download
      @local_files = find_local_files
      download_files
    rescue RestClient::Forbidden
      @spinner.error('invalid access token')
      exit 1
    end

    private

      def download_files
        @files.each do |file|
          download_proc = method(:download_file).curry[file]
          @download_spinners.register("[#{@pastel.yellow(':spinner')}] #{file[:path]}", &download_proc)
        end
        @download_spinners.auto_spin
      end

      def download_file(file, spinner)
        return mark_unchanged(spinner) if @local_files[file[:path]] == file[:sha1]

        file[:document].download(file[:locale].code, path: file[:path])
        spinner.success(@pastel.green('done'))
      rescue StandardError => e
        spinner.error(@pastel.red("error: #{e.message}"))
      end

      def mark_unchanged(spinner)
        spinner.instance_variable_set(:@success_mark, @pastel.blue('='))
        spinner.success(@pastel.blue('skipping unchanged file'))
      end

      def find_local_files
        @spinner.update(title: 'Finding local files...')
        @spinner.auto_spin
        files = FileFinder.local_files(project)
        @spinner.success(@pastel.green("found #{files.count} file(s)"))
        files
      end

      def path(document, locale)
        document.path.gsub('{locale_code}', locale.code)
      end

      def project_locales
        @project_locales ||= project.locales
      end

      def project
        @project ||= ToptranslationCli.connection.projects.find(ToptranslationCli.configuration.project_identifier)
      end

      def files_to_download
        @spinner.update(title: 'Checking remote files...')
        @spinner.auto_spin
        files = project&.documents&.flat_map do |document|
          document.translations.map do |translation|
            file_to_download(document, translation)
          end
        end
        @spinner.success(@pastel.green('done'))
        files
      end

      def file_to_download
        {
          path: path(document, translation.locale),
          document: document,
          sha1: translation.sha1,
          locale: translation.locale
        }
      end
  end
end
