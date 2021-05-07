# frozen_string_literal: true

require 'fileutils'
require 'tty-spinner'
require 'pastel'
require 'tty-progressbar'

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
    end

    def run
      changed = changed_files(remote_files, local_files)
      download_files(changed)
    rescue RestClient::BadRequest
      @spinner.error(@pastel.red('invalid access token')) if @spinner.spinning?
      exit 1
    rescue RestClient::NotFound
      @spinner.error(@pastel.red('project not found')) if @spinner.spinning?
      exit 1
    end

    private

      def changed_files(remote_files, local_files)
        @spinner.update(title: 'Checking for changed files...')
        files = remote_files.reject do |file|
          local_files[file[:path]] == file[:sha1]
        end
        @spinner.auto_spin
        @spinner.success(@pastel.green("found #{files.count} changed file(s)"))
        files
      end

      def download_files(files)
        return if files.empty?

        bar = TTY::ProgressBar.new('Downloading [:bar] :percent [:current/:total]', total: files.count)
        bar.render

        files.each_in_threads(8) do |file|
          file[:document].download(file[:locale].code, path: file[:path])
          bar.synchronize { bar.log(file[:path]) }
          bar.advance
        end
      end

      def local_files
        @spinner.update(title: 'Checking local files...')
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

      def remote_files
        @spinner.update(title: 'Checking remote files...')
        @spinner.auto_spin
        files = project&.documents&.flat_map do |document|
          document.translations.map do |translation|
            file_to_download(document, translation)
          end
        end
        @spinner.success(@pastel.green("found #{files.count} file(s)"))
        files
      end

      def file_to_download(document, translation)
        {
          path: path(document, translation.locale),
          document: document,
          sha1: translation.sha1,
          locale: translation.locale
        }
      end
  end
end
