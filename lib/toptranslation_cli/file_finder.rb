module ToptranslationCli
  class FileFinder
    def initialize(path_definition)
      @path_definition = path_definition
    end

    def files(locale_code='**')
      Dir.glob( @path_definition['path'].gsub('{locale_code}', locale_code) )
    end
  end
end
