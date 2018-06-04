# frozen_string_literal: true

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
    attr_writer :configuration

    def configuration
      @configuration ||= Configuration.new
    end

    def connection
      @connection ||= Toptranslation.new(access_token: configuration.access_token,
                                         base_url: configuration.api_base_url,
                                         files_url: configuration.files_base_url,
                                         verbose: configuration.verbose)
    end
  end
end
