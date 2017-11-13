module ToptranslationCli
  class Configuration
    attr_accessor :project_identifier, :access_token, :files, :api_base_url, :files_base_url

    def load
      configuration = JSON.parse(File.read('toptranslation.json')) rescue {}
      @project_identifier = configuration['project_identifier']
      @access_token = configuration['access_token']
      @files = configuration['files'] || []
      @files_base_url = configuration['files_base_url'] || 'https://files.toptranslation.com'
      @api_base_url = configuration['api_base_url'] || 'https://api.toptranslation.com/v0'
    end

    def save
      File.open('toptranslation.json', 'w') do |file|
        file.write(JSON.pretty_generate(configuration_hash))
      end
    end

    def use_examples
      @project_identifier = '<PROJECT_IDENTIFIER>'
      @access_token = '<YOUR_ACCESS_TOKEN>'
      @files = [ { path: 'config/locales/{locale_code}/**/*.yml' } ]
    end

    private
      def configuration_hash
        {
          project_identifier: @project_identifier,
          access_token: @access_token,
          files: @files,
          api_base_url: @api_base_url
        }
      end
  end
end
