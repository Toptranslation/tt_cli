require 'spec_helper'

describe ToptranslationCli::Configuration do
  context :use_examples do
    it 'should set example values' do
      ToptranslationCli.configuration.use_examples

      expect(ToptranslationCli.configuration.project_identifier).to be_kind_of(String)
      expect(ToptranslationCli.configuration.access_token).to be_kind_of(String)
      expect(ToptranslationCli.configuration.files.length).to be > 0
    end
  end

  context :load do
    let(:configuration_example) do
      {
        "project_identifier": "a_custom_project_identifier",
        "access_token": "a_custom_access_token",
        "files": [ { "path": "config/locales/{locale_code}/**/*.yml" } ],
        "api_base_url": 'http://foobar.example.com'
      }
    end

    before(:each) do
      allow(File).to receive(:read).and_return(configuration_example.to_json)
    end

    it 'should set attributes correctly' do
      allow(File).to receive(:read).and_return(configuration_example.to_json)
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration.project_identifier).to eq(configuration_example[:project_identifier])
      expect(ToptranslationCli.configuration.access_token).to eq(configuration_example[:access_token])
      expect(ToptranslationCli.configuration.api_base_url).to eq(configuration_example[:api_base_url])
      expect(ToptranslationCli.configuration.files.count).to eq(configuration_example[:files].count)
    end

    it 'should fallback to [] for files if not given' do
      configuration_example[:files] = nil
      allow(File).to receive(:read).and_return(configuration_example.to_json)
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration.files).to eq([])
    end

    it 'should fallback to production api base url' do
      configuration_example[:api_base_url] = nil
      allow(File).to receive(:read).and_return(configuration_example.to_json)
      ToptranslationCli.configuration.load
      expect(ToptranslationCli.configuration.api_base_url).to eq('https://api.toptranslation.com')
    end
  end

  context :save do
    it 'should call File.open on toptranslation.json' do
      expect(File).to receive(:open).with('toptranslation.json', 'w').and_return(true)
      ToptranslationCli.configuration.save
    end
  end
end
