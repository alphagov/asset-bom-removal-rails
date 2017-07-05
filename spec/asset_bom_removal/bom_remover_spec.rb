require 'spec_helper'
require 'asset_bom_removal/bom_remover'
require 'zlib'

RSpec.describe AssetBomRemoval::BomRemover do
  let(:logger) { double(:logger, info: nil, error: nil, warn: nil, debug: nil, fatal: nil) }
  let(:tmp_path) { Dir.mktmpdir }
  let(:bom_bytes) { [0xEF, 0xBB, 0xBF] }
  subject { described_class.new(tmp_path, logger) }

  before do
    FileUtils.cp_r Dir.glob(fixture_file_path(File.join('**', '*.{css,gz}'))), tmp_path
  end

  after do
    FileUtils.remove_dir tmp_path
  end

  def css_file_name(file_name)
    File.join(tmp_path, "#{file_name}.css")
  end

  def gzipped_css_file_name(file_name)
    File.join(tmp_path, "#{file_name}.css.gz")
  end

  it 'changes the CSS file with a BOM in it' do
    file_name = css_file_name 'theres-a-bom-in-here'
    before_time = File.mtime(file_name)
    sleep(0.1)
    subject.do_it
    expect(File.mtime(file_name)).not_to eq(before_time)
  end

  it 'strips the BOM from the CSS file with a BOM in it' do
    file_name = css_file_name 'theres-a-bom-in-here'
    expect(File.binread(file_name).bytes.take(3)).to eq(bom_bytes)
    subject.do_it
    expect(File.binread(file_name).bytes.take(3)).not_to eq(bom_bytes)
  end

  it 'does nothing to the CSS file without a BOM in it' do
    file_name = css_file_name 'no-bom-in-here'
    before_time = File.mtime(file_name)
    sleep(0.1)
    subject.do_it
    expect(File.mtime(file_name)).to eq(before_time)
  end

  it 'changes the gzipped version of the CSS file with a BOM in it' do
    file_name = gzipped_css_file_name 'theres-a-bom-in-here'
    before_time = File.mtime(file_name)
    sleep(0.1)
    subject.do_it
    expect(File.mtime(file_name)).not_to eq(before_time)
  end

  it 'strips the BOM from the gzipped version of the CSS file with a BOM in it' do
    file_name = gzipped_css_file_name 'theres-a-bom-in-here'
    Zlib::GzipReader.open(file_name) do |gz|
      expect(gz.each_byte.take(3)).to eq(bom_bytes)
    end
    subject.do_it
    Zlib::GzipReader.open(file_name) do |gz|
      expect(gz.each_byte.take(3)).not_to eq(bom_bytes)
    end
  end

  it 'does not create a gzipped version of the CSS file with a BOM in it if there was not one in the first place' do
    file_name = gzipped_css_file_name 'theres-a-bom-in-here'
    FileUtils.rm(file_name)
    subject.do_it
    expect(File.exist?(file_name)).to be_falsy
  end

  it 'does nothing to the gzipped version of the CSS file without a BOM in it' do
    file_name = gzipped_css_file_name 'no-bom-in-here'
    before_time = File.mtime(file_name)
    sleep(0.1)
    subject.do_it
    expect(File.mtime(file_name)).to eq(before_time)
  end

  it 'does nothing to a non-CSS file with a BOM in it' do
    file_name = css_file_name 'theres-a-bom-in-here'
    not_css_file_name = file_name.sub(/\.css$/, '.js')
    FileUtils.mv(file_name, not_css_file_name)
    before_time = File.mtime(not_css_file_name)
    sleep(0.1)
    subject.do_it
    expect(File.mtime(not_css_file_name)).to eq(before_time)
  end

  it 'does not strip the BOM from a non-CSS file with a BOM in it' do
    file_name = css_file_name 'theres-a-bom-in-here'
    not_css_file_name = file_name.sub(/\.css$/, '.js')
    FileUtils.mv(file_name, not_css_file_name)
    expect(File.binread(not_css_file_name).bytes.take(3)).to eq(bom_bytes)
    subject.do_it
    expect(File.binread(not_css_file_name).bytes.take(3)).to eq(bom_bytes)
  end
end
