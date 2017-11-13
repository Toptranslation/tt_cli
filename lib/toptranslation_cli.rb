require 'paint'
require 'toptranslation_api'

require 'toptranslation_cli/check'
require 'toptranslation_cli/configuration'
require 'toptranslation_cli/file_finder'
require 'toptranslation_cli/info'
require 'toptranslation_cli/initializer'
require 'toptranslation_cli/placeholder_path'
require 'toptranslation_cli/pull'
require 'toptranslation_cli/push'
require 'toptranslation_cli/version'

module ToptranslationCli
  class << self
    attr_accessor :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.connection
    @connection ||= ToptranslationApi.new( access_token: configuration.access_token,
                                        base_url: configuration.api_base_url,
                                        files_url: configuration.files_base_url,
                                        verbose: true
                                      )
  end
end
