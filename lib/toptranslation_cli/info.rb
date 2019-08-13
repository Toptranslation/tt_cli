# frozen_string_literal: true

module ToptranslationCli
  class Info
    def self.print_help
      print_version

      puts <<~INFO
        Usage:\t\ttt [command]\n\n"
        Commands:'
           init\t\tCreates example configuration file #{Configuration::FILENAME}"
           check\tChecks current configuration"
           push\t\tUploads local documents"
           pull\t\tPulls remote translations, overwrites local documents"
           --version\tDisplays current version of application"
           --help\tDisplays this help screen\n\n"
        Twitter:\t@tt_developers\n\n"
        Websites:\thttps://www.toptranslation.com"
        \t\thttps://developer.toptranslation.com"
        \t\thttps://github.com/Toptranslation/tt_cli"
      INFO
    end

    def self.print_version
      puts "Toptranslation command line client, version #{VERSION}"
    end
  end
end
