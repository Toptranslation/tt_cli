# frozen_string_literal: true

require 'pastel'
require 'tty-prompt'
require 'tty-spinner'

module ToptranslationCli
  class Initializer # rubocop:disable Metrics/ClassLength
    class << self
      def run
        new.run
      end
    end

    def initialize
      @prompt = TTY::Prompt.new
      @client = ToptranslationCli.connection
      @pastel = Pastel.new
      format = "[#{@pastel.yellow(':spinner')}] :title"
      @spinner = TTY::Spinner.new(format, success_mark: @pastel.green('+'), error_mark: @pastel.red('-'))
    end

    def run
      create_config(ask_config)
      @prompt.ok("Generated #{Configuration::FILENAME}")
    end

    private

      def ask_config
        {
          token: sign_in(ask_auth_method),
          project_id: ask_project,
          file_selectors: ask_file_selectors
        }
      end

      def projects?
        @spinner.update(title: 'Fetching projects...')
        @spinner.auto_spin
        @client.projects.any?.tap do |any|
          if any
            @spinner.success(@pastel.green('done'))
          else
            @spinner.error(@pastel.red('could not find any projects'))
          end
        end
      end

      def ask_project
        exit 1 unless projects?

        @prompt.select('Project:') do |menu|
          each_project_with_index.map do |project, index|
            menu.default(index + 1) if File.basename(Dir.pwd).casecmp?(project.name)
            menu.choice name: project.name, value: project.identifier
          end
        end
      end

      def ask_auth_method
        @prompt.select('Authentication method:') do |menu|
          menu.choice name: 'Email and password', value: :email
          menu.choice name: 'Access token', value: :token
        end
      end

      def ask_file_selectors
        result = []
        loop do
          result << @prompt.ask('File selector:') do |q|
            q.required true
            q.default 'config/locales/{locale_code}/**/*.yml'
          end
          break unless @prompt.yes?('Add another file selector?', default: false)
        end
        result
      end

      def sign_in(auth_method)
        @spinner.update(title: 'Signing in...')
        if auth_method == :email
          ask_email_and_password
        else
          ask_access_token
        end
      end

      def ask_email_and_password
        email = @prompt.ask('Email:', required: true)
        password = @prompt.mask('Password:', required: true, echo: false)
        token = @client.sign_in!(email: email, password: password)
        @spinner.success(@pastel.green('done'))
        token
      rescue RestClient::Unauthorized
        @spinner.error(@pastel.red('credentials are invalid'))
        retry
      end

      def ask_access_token
        token = @prompt.ask('Access token:', required: true)
        @client.access_token = token
        @spinner.auto_spin
        @client.projects.to_a
        @spinner.success(@pastel.green('done'))
        token
      rescue RestClient::Forbidden
        @spinner.error(@pastel.red('invalid access token'))
        @spinner.stop
        retry
      end

      def create_config(answers)
        config = ToptranslationCli::Configuration.new
        config.project_identifier = answers[:project_id]
        config.access_token = answers[:token]
        config.files = answers[:file_selectors]
        config.save
      end

      def each_project_with_index
        @client.projects.sort_by(&:name).each_with_index
      end
  end
end
