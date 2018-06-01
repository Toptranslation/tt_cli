# frozen_string_literal: true

RSpec.describe ToptranslationCli::Configuration do
  context :use_examples do
    it 'sets example values' do
      ToptranslationCli.configuration.use_examples
      expect(ToptranslationCli.configuration).to have_attributes(
        project_identifier: '<PROJECT_IDENTIFIER>',
        access_token: '<YOUR_ACCESS_TOKEN>',
        files: [{ path: 'config/locales/{locale_code}/**/*.yml' }]
      )
    end
  end

  context :load do
    let(:configuration_example) do
      {
        project_identifier: 'a_custom_project_identifier',
        access_token: 'a_custom_access_token',
        files: [{ path: 'config/locales/{locale_code}/**/*.yml' }],
        api_base_url: 'http://foobar.example.com'
      }
    end

    before do
      allow(File).to receive(:read).and_return(configuration_example.to_json)
    end

    it 'sets attributes correctly' do
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration).to have_attributes(
        project_identifier: configuration_example[:project_identifier],
        access_token:       configuration_example[:access_token],
        api_base_url:       configuration_example[:api_base_url],
        files:              configuration_example[:files]
      )
    end

    it 'fallbacks to [] for files if not given' do
      configuration_example[:files] = nil
      allow(File).to receive(:read).and_return(configuration_example.to_json)
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration.files).to eq([])
    end

    it 'fallbacks to production api base url' do
      configuration_example[:api_base_url] = nil
      allow(File).to receive(:read).and_return(configuration_example.to_json)
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration.api_base_url).to eq('https://api.toptranslation.com')
    end
  end

  context :save do
    it 'calls File.open on toptranslation.json' do
      allow(File).to receive(:open)
      ToptranslationCli.configuration.save
      expect(File).to have_received(:open).with('toptranslation.json', 'w')
    end
  end
end
