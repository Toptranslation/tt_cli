module ToptranslationCli
  class Check
    def self.run
      puts "Toptranslation command line client, version #{ VERSION } - Configuration check\n\n"
      puts "Configuration file present:\t#{ check_configuration_file }"
      puts " * includes access_token:\t#{ check_access_token }"
      puts " * includes project_identifier:\t#{ check_project_identifier }"
      puts " * includes files:\t\t#{ check_file_paths_present }\n\n"

      puts "Checking connection:"
      puts " * API URL:\t\t\t#{ ToptranslationCli.configuration.api_base_url }"
      puts " * Files URL:\t\t\t#{ ToptranslationCli.configuration.files_base_url }"
      puts " * access_token:\t\t#{ ToptranslationCli.configuration.access_token }"
      puts " * project_identifier:\t\t#{ ToptranslationCli.configuration.project_identifier }"
      puts " * project found:\t\t#{ check_for_project }\n\n"

      check_matching_files
    end

    def self.check_configuration_file
      if File.exist?('toptranslation.json')
        Paint['ok', :green]
      else
        Paint['configuration file missing', :red]
      end
    end

    def self.check_access_token
      ToptranslationCli.configuration.load
      if ToptranslationCli.configuration.access_token != nil
        Paint['ok', :green]
      else
        Paint['access token missing from configuration file', :red]
      end
    end

    def self.check_project_identifier
      ToptranslationCli.configuration.load
      if ToptranslationCli.configuration.project_identifier != nil
        Paint['ok', :green]
      else
        Paint['project_identifier missing from configuration file', :red]
      end
    end

    def self.check_for_project
      project_identifier = ToptranslationCli.configuration.project_identifier
      remote_project = ToptranslationCli.connection.projects.find(project_identifier) rescue nil

      if  remote_project&.identifier == project_identifier
        Paint['ok', :green]
      else
        Paint['project not found', :red]
      end
    end

    def self.check_file_paths_present
      ToptranslationCli.configuration.load
      if ToptranslationCli.configuration.files.any?
        Paint['ok', :green]
      else
        Paint['file paths missing from configuration file', :red]
      end
    end

    def self.check_matching_files
      puts "Matching files:"

      ToptranslationCli.configuration.load
      ToptranslationCli.configuration.files.each do |path_definition|
        puts " * #{ path_definition['path'] }: #{ matching_files_output(path_definition)}"
      end
    end

    private
      def self.matching_files_output(path_definition)
        count = FileFinder.new(path_definition).files.count

        if count!=0
          Paint["#{ count } matching files", :green]
        else
          Paint['no matching files', :red]
        end
      end
  end
end
