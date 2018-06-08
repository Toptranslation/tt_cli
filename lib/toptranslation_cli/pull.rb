# frozen_string_literal: true

require 'fileutils'

module ToptranslationCli
  class Pull
    class << self
      def run
        ToptranslationCli.configuration.load

        multibar = TTY::ProgressBar::Multi.new

        files = project&.documents&.flat_map do |document|
          document.translations.take(1).map do |translation|
            file = {
              path: document.path.gsub('{locale_code}', translation.locale.code),
              document: document,
              locale_code: translation.locale.code,
              bar: multibar.register('[:bar]', total: 100)
            }
            format_bar!(file, :checking)
            file
          end
        end

        local_files = FileFinder.local_files(project)

        files.sort_by { |f| f[:path] }.map do |file|
          Thread.new do
            begin
              if local_files[file[:path]] == file[:sha1]
                format_bar!(file, :skipping)
                file[:bar].stop
                Thread.current.exit
              end

              format_bar!(file, :fetching_url)
              download_url = file[:document].download_url(file[:locale_code], file_type: 'yaml')

              format_bar!(file, :preparing)
              downloading = false

              download(download_url, file[:path]) do |n, total|
                file[:bar].update(total: total) if total && total != file[:bar].total
                format_bar!(file, :downloading) unless downloading
                downloading = true
                file[:bar].advance(n)
              end
            rescue StandardError => e
              file[:error] = e
              format_bar!(file, :error)
            end
          end
        end.map(&:join)
      end

      private

      def download(url, path)
        uri = URI.parse(url)
        Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
          total = content_length(http, uri)
          yield 0, total

          FileUtils.mkpath(File.dirname(path))
          File.open(path, 'w') do |file|
            http.request_get(uri.request_uri) do |response|
              response.read_body do |data|
                file.write(data)
                yield data.length, total
              end
            end
          end
        end
      end

      def content_length(http, uri)
        sleep_time = 0.5
        attempts = 0
        total = nil

        loop do
          raise 'File not available' if attempts >= 10

          head_response = http.request_head(uri.request_uri)
          total = head_response['content-length'].to_i
          break if head_response.code == '200'

          attempts += 1
          sleep sleep_time
          sleep_time += sleep_time * 0.5
        end

        total
      end

      def format_bar!(file, state)
        format = case state
                 when :checking then "#{file[:path]}: Checking..."
                 when :skipping then "#{file[:path]}: Skipping unchanged file"
                 when :fetching_url then "#{file[:path]}: Fetching download URL..."
                 when :preparing then "#{file[:path]}: Preparing file to download..."
                 when :error then "#{file[:path]}: #{state} Error: #{file[:error].inspect}"
                 when :downloading then "#{file[:path]}: [:bar] :percent"
                 end
        file[:bar].instance_variable_set(:@format, format)
        file[:bar].render
      end

      def sha1_checksum(path)
        Digest::SHA1.file(path).hexdigest
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
    end
  end
end
