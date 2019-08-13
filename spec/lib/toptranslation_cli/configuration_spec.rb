# frozen_string_literal: true

RSpec.describe ToptranslationCli::Configuration do
  it 'sets example values' do # rubocop:disable RSpec/ExampleLength
    ToptranslationCli.configuration.use_examples
    expect(ToptranslationCli.configuration).to have_attributes(
      project_identifier: '<PROJECT_IDENTIFIER>',
      access_token: '<YOUR_ACCESS_TOKEN>',
      files: ['config/locales/{locale_code}/**/*.yml']
    )
  end

  describe '.load' do
    let(:configuration_example) do
      {
        'project_identifier' => 'a_custom_project_identifier',
        'access_token' => 'a_custom_access_token',
        'files' => ['config/locales/{locale_code}/**/*.yml'],
        'api_base_url' => 'http://foobar.example.com'
      }
    end

    before do
      allow(File).to receive(:read) { Psych.dump(configuration_example) }
    end

    after do
      ToptranslationCli.instance_variable_set(:@configuration, nil)
    end

    it 'sets attributes correctly' do # rubocop:disable RSpec/ExampleLength
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration).to have_attributes(
        project_identifier: configuration_example['project_identifier'],
        access_token: configuration_example['access_token'],
        api_base_url: configuration_example['api_base_url'],
        files: configuration_example['files']
      )
    end

    context 'when files configuration is missing' do
      let(:configuration_example) do
        {
          'project_identifier' => 'a_custom_project_identifier',
          'access_token' => 'a_custom_access_token',
          'api_base_url' => 'http://foobar.example.com'
        }
      end

      it 'falls back to []' do
        ToptranslationCli.configuration.load
        expect(ToptranslationCli.configuration.files).to eq([])
      end
    end

    context 'when no api base url is set' do
      let(:configuration_example) do
        {
          'project_identifier' => 'a_custom_project_identifier',
          'access_token' => 'a_custom_access_token',
          'files' => ['config/locales/{locale_code}/**/*.yml']
        }
      end

      it 'falls back to production api base url' do
        ToptranslationCli.configuration.load
        expect(ToptranslationCli.configuration.api_base_url).to eq('https://api.toptranslation.com')
      end
    end
  end

  describe '.save' do
    it 'calls File.open on .toptranslation.yml' do
      allow(File).to receive(:open)
      ToptranslationCli.configuration.save
      expect(File).to have_received(:open).with('.toptranslation.yml', 'w')
    end
  end
end
