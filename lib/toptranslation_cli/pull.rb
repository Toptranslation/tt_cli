# frozen_string_literal: true

require 'fileutils'

module ToptranslationCli
  class Pull
    class << self
      def run
        ToptranslationCli.configuration.load
        project&.documents&.each do |document|
          project_locales.each do |locale|
            response = document.download(locale.code, 'yaml')
            next unless response
            path = path(document, locale)

            if File.exist?(path) && sha1_checksum(path) == response['sha1']
              puts "Skipping unchanged file #{path}"
            else
              puts "Creating file: #{path}"
              puts "# Downloading: #{url}" if @verbose

              FileUtils.mkpath(File.dirname(path))

              file = File.open(path, 'w+')
              RestClient.get response['download_url'] do |stream|
                file.write stream
              end
              file.close
            end
          end
        end
      end

      private

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
