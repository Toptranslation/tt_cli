require 'spec_helper'

describe ToptranslationCli::FileFinder do
  let(:path) { '/foo/{locale_code}/*.yml' }
  let(:path_without_placeholder) { '/foo/*.yml' }
  let(:locale_code) { 'de' }

  it 'should replace locale_code placeholder' do
    expect(Dir).to receive(:glob).with("/foo/#{ locale_code }/*.yml")
    ToptranslationCli::FileFinder.new({ 'path' => path }).files('de')
  end

  it 'should replace locale_code with wildcard if no locale is given' do
    expect(Dir).to receive(:glob).with("/foo/**/*.yml")
    ToptranslationCli::FileFinder.new({ 'path' => path }).files
  end

  it 'should not change path if no place_holder is present' do
    expect(Dir).to receive(:glob).with("/foo/*.yml")
    ToptranslationCli::FileFinder.new({ 'path' => path_without_placeholder }).files
  end
end
