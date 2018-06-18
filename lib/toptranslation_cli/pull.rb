# frozen_string_literal: true

require 'fileutils'

module ToptranslationCli
  class Pull
    class << self
      def run
        ToptranslationCli.configuration.load

        multibar = TTY::ProgressBar::Multi.new
        files = files_to_download
        local_files = FileFinder.local_files(project)

        files.sort_by { |f| f[:placeholder_path] }.map do |file|
          bar = multibar.register('checking...', total: 100)
          handle_file_in_thread(file, bar, local_files)
        end.map(&:join)
      end

      private

      def handle_file_in_thread(file, bar, local_files)
        Thread.new do
          begin
            if local_files[file[:path]] == file[:sha1]
              format_bar!(bar, file, :skipping)
              bar.stop
              Thread.current.exit
            end

            format_bar!(bar, file, :preparing)
            download(file, bar)
          rescue StandardError => e
            file[:error] = e
            format_bar!(bar, file, :error)
          end
        end
      end

      def format_bar!(bar, file, state)
        format = case state
                 when :skipping then "#{file[:path]}: Skipping unchanged file"
                 when :preparing then "#{file[:path]}: Preparing file to download..."
                 when :error then "#{file[:path]}: #{state} Error: #{file[:error].inspect}"
                 when :downloading then "#{file[:path]}: [:bar] :percent"
                 end
        bar.instance_variable_set(:@format, format)
        bar.render
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
        project&.documents&.flat_map do |document|
          document.translations.map do |translation|
            {
              path: path(document, translation.locale),
              document: document,
              sha1: translation.sha1,
              locale: translation.locale
            }
          end
        end
      end

      def download(file, bar)
        file[:document].download(file[:locale].code, path: file[:path], file_type: 'yaml') do |n, total|
          bar.update(total: total) if total && total != bar.total
          format_bar!(bar, file, :downloading) if n.nil?
          bar.advance(n) if n
        end
      end
    end
  end
end
