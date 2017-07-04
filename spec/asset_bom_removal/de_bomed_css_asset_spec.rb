require "spec_helper"
require "asset_bom_removal/de_bomed_css_asset"

RSpec.describe AssetBomRemoval::DeBomedCssAsset do
  let(:css_file_path) { fixture_file_path 'no-bom-in-here.css' }
  subject { described_class.new(css_file_path) }

  it 'has text/css for content_type' do
    expect(subject.content_type).to eq 'text/css'
  end

  it 'exposes the charset of the file' do
    expect(subject.charset).to eq File.read(css_file_path).encoding.to_s
  end

  it 'exposes the full source of the file' do
    expect(subject.source).to eq File.read(css_file_path)
  end

  it 'exposes its own file name' do
    expect(subject.file_name).to eq css_file_path
  end
end
