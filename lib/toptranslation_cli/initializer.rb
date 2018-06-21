# frozen_string_literal: true

require 'tty-prompt'

module ToptranslationCli
  class Initializer
    class << self
      def run
        new.run
      end
    end

    def initialize
      @prompt = TTY::Prompt.new
      @client = Toptranslation.new({})
    end

    def run
      answers = ask_config
      create_config(answers)
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

      def ask_project
        if @client.projects.none?
          @prompt.error('Could not find any projects')
          exit 1
        end

        project_choices = @client.projects.map do |project|
          { name: project.name, value: project.identifier }
        end

        @prompt.select('Project:', project_choices)
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
        if auth_method == :email
          ask_email_and_password
        else
          ask_access_token
        end
      end

      def ask_email_and_password
        loop do
          email = @prompt.ask('Email:', required: true)
          password = @prompt.mask('Password:', required: true, echo: false)
          begin
            return @client.sign_in!(email: email, password: password)
          rescue RestClient::Unauthorized
            @prompt.error('Credentials are invalid')
          end
        end
      end

      def ask_access_token
        loop do
          begin
            access_token = @prompt.ask('Access token:', required: true)
            @client.access_token = access_token
            return access_token if @client.projects.to_a
          rescue RestClient::Forbidden
            @prompt.error('Invalid access token')
          end
        end
      end

      def create_config(answers)
        config = ToptranslationCli::Configuration.new
        config.project_identifier = answers[:project_id]
        config.access_token = answers[:token]
        config.files = answers[:file_selectors]
        config.save
      end
  end
end
