# frozen_string_literal: true

module ToptranslationCli
  class Initializer
    def self.run
      puts "Creating example configuration in '#{Configuration::FILENAME}'.\n\n"

      ToptranslationCli.configuration.use_examples
      ToptranslationCli.configuration.save

      puts 'See https://developer.toptranslation.com for configuration instructions.'
    end
  end
end
