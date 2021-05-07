# frozen_string_literal: true

module ToptranslationCli
  class Check
    class << self
      def run # rubocop:disable Metrics/AbcSize, Metrics/MethodLength
        puts "Toptranslation command line client, version #{VERSION} - Configuration check\n\n"
        puts "Configuration file present:\t#{check_configuration_file}"
        puts " * includes access_token:\t#{check_access_token}"
        puts " * includes project_identifier:\t#{check_project_identifier}"
        puts " * includes files:\t\t#{check_file_paths_present}\n\n"

        puts 'Checking connection:'
        puts " * API URL:\t\t\t#{ToptranslationCli.configuration.api_base_url}"
        puts " * Files URL:\t\t\t#{ToptranslationCli.configuration.files_base_url}"
        puts " * access_token:\t\t#{ToptranslationCli.configuration.access_token}"
        puts " * project_identifier:\t\t#{ToptranslationCli.configuration.project_identifier}"
        puts " * project found:\t\t#{check_for_project}\n\n"

        check_matching_files
      end

      private

        def check_configuration_file
          if ToptranslationCli.configuration.exist?
            pastel.green('ok')
          else
            pastel.red('configuration file missing')
          end
        end

        def check_access_token
          ToptranslationCli.configuration.load
          if ToptranslationCli.configuration.access_token.nil?
            pastel.red('access token missing from configuration file')
          else
            pastel.green('ok')
          end
        end

        def check_project_identifier
          ToptranslationCli.configuration.load
          if ToptranslationCli.configuration.project_identifier.nil?
            pastel.red('project_identifier missing from configuration file')
          else
            pastel.green('ok')
          end
        end

        def find_remote_project(project_identifier)
          ToptranslationCli.connection.projects.find(project_identifier)
        rescue StandardError => e
          puts pastel.red(e)
        end

        def check_for_project
          project_identifier = ToptranslationCli.configuration.project_identifier
          remote_project = find_remote_project(project_identifier)

          if remote_project&.identifier == project_identifier
            pastel.green('ok')
          else
            pastel.red('project not found')
          end
        end

        def check_file_paths_present
          ToptranslationCli.configuration.load
          if ToptranslationCli.configuration.files.any?
            pastel.green('ok')
          else
            pastel.red('file paths missing from configuration file')
          end
        end

        def check_matching_files
          puts 'Matching files:'

          ToptranslationCli.configuration.load
          ToptranslationCli.configuration.files.each do |path_definition|
            puts " * #{path_definition}: #{matching_files_output(path_definition)}"
          end
        end

        def matching_files_output(path_definition)
          count = FileFinder.new(path_definition).files.count

          if count.zero?
            pastel.red('no matching files')
          else
            pastel.green("#{count} matching files")
          end
        end

        def pastel
          @pastel ||= Pastel.new
        end
    end
  end
end
