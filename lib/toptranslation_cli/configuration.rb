# frozen_string_literal: true

module ToptranslationCli
  class Configuration
    attr_accessor :project_identifier, :access_token, :files, :api_base_url, :files_base_url, :verbose

    FILENAME = '.toptranslation.yml'

    def initialize
      @files_base_url = 'https://files.toptranslation.com'
      @api_base_url = 'https://api.toptranslation.com'
      @verbose = !ENV['VERBOSE'].nil?
    end

    def load
      @project_identifier = configuration['project_identifier']
      @access_token = configuration['access_token']
      @files_base_url = configuration['files_base_url'] || @files_base_url
      @api_base_url = configuration['api_base_url'] || @api_base_url
      @files = configuration['files'] || []
    end

    def save
      File.open(FILENAME, 'w') do |file|
        # Psych can't stringify keys so we dump it to json before dumping to yml
        Psych.dump(JSON.parse(configuration_hash.to_json), file)
      end
    end

    def use_examples
      @project_identifier = '<PROJECT_IDENTIFIER>'
      @access_token = '<YOUR_ACCESS_TOKEN>'
      @files = ['config/locales/{locale_code}/**/*.yml']
    end

    def exist?
      File.exist?(FILENAME)
    end

    private

      def configuration
        @configuration ||= Psych.safe_load(File.read(FILENAME, encoding: 'bom|utf-8'))
      rescue StandardError => e
        puts Pastel.new.red('Could not read configuration'), e
        exit 1
      end

      def configuration_hash
        {
          project_identifier: @project_identifier,
          access_token: @access_token,
          files: @files
        }
      end
  end
end
