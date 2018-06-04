# frozen_string_literal: true

RSpec.describe ToptranslationCli::FileFinder do
  let(:path) { '/foo/{locale_code}/*.yml' }
  let(:path_without_placeholder) { '/foo/*.yml' }
  let(:locale_code) { 'de' }

  before do
    allow(Dir).to receive(:glob)
  end

  it 'replaces locale_code placeholder' do
    described_class.new('path' => path).files('de')
    expect(Dir).to have_received(:glob).with("/foo/#{locale_code}/*.yml")
  end

  it 'replaces locale_code with wildcard if no locale is given' do
    described_class.new('path' => path).files
    expect(Dir).to have_received(:glob).with('/foo/**/*.yml')
  end

  it 'does not change path if no place_holder is present' do
    described_class.new('path' => path_without_placeholder).files
    expect(Dir).to have_received(:glob).with('/foo/*.yml')
  end
end
