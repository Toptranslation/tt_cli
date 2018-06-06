# frozen_string_literal: true

module ToptranslationCli
  class FileFinder
    def initialize(path_definition)
      @path_definition = path_definition
    end

    def files(locale_code = '**')
      Dir.glob(@path_definition.gsub('{locale_code}', locale_code))
    end

    class << self
      def local_files(project)
        ToptranslationCli.configuration.files.each_with_object({}) do |path_definition, mem|
          project&.locales&.map(&:code)&.each do |locale_code|
            mem.merge!(local_files_for_path_definition(path_definition, locale_code))
          end
        end
      end

      def local_files_for_path_definition(path_definition, locale_code)
        new(path_definition)
          .files(locale_code)
          .map { |path| { path => checksum(path) } }
          .reduce({}, &:merge)
      end

      def remote_files(project)
        project_locales = project&.locales
        project&.documents&.each_with_object({}) do |document, files|
          project_locales&.each do |locale|
            translation = document.translations.find { |t| t.locale.code == locale.code }
            next unless translation
            path = document.path.gsub('{locale_code}', locale.code)
            sha1 = translation.sha1
            files[path] = sha1
          end
        end
      end

      def checksum(path)
        Digest::SHA1.file(path).hexdigest
      end
    end
  end
end
