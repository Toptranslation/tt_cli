require 'fileutils'

module ToptranslationCli
  class Pull
    def self.run
      ToptranslationCli.configuration.load
      project&.documents.each do |document|
        project_locales.each do |locale|
          if response = document.download(locale.code, 'yaml')
            path = path(document, locale)

            if File.exist?(path) && sha1_checksum(path) == response['sha1']
              puts "Skipping unchanged file #{ path }"
            else
              puts "Creating file: #{ path }"
              puts "# Downloading: #{ url }" if @verbose

              FileUtils.mkpath( File.dirname(path) )

              file = File.open(path, 'w+')
              RestClient.get response['download_url'] do |stream|
                file.write stream
              end
              file.close
            end
          end
        end
      end
    end

    private
      def self.sha1_checksum(path)
        Digest::SHA1.file(path).hexdigest
      end

      def self.path(document, locale)
        document.path.gsub('{locale_code}', locale.code)
      end

      def self.project_locales
        @project_locales ||= project.locales
      end

      def self.project
        @project ||= ToptranslationCli.connection.projects.find(ToptranslationCli.configuration.project_identifier)
      end
  end
end
