module ToptranslationCli
  class Info
    def self.print_help
      print_version

      puts "\n"
      puts "Usage:\t\ttt [command]\n\n"
      puts "Commands:"
      puts "   init\t\tCreates example configuration file toptranslation.json"
      puts "   check\tChecks current configuration"
      puts "   push\t\tUploads local documents"
      puts "   pull\t\tPulls remote translations, overwrites local documents"
      puts "   --version\tDisplays current version of application"
      puts "   --help\tDisplays this help screen\n\n"
      puts "Twitter:\t@tt_developers\n\n"
      puts "Websites:\thttps://www.toptranslation.com"
      puts "\t\thttps://developer.toptranslation.com"
      puts "\t\thttps://github.com/Toptranslation/toptranslation_cli"
    end

    def self.print_version
      puts "Toptranslation command line client, version #{ VERSION }"
    end
  end
end
