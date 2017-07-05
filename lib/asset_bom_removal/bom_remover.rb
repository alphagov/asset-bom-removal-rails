require 'sprockets/utils/gzip'
require 'sprockets/path_utils'
require 'asset_bom_removal/de_bomed_css_asset'

module AssetBomRemoval
  class BomRemover
    def initialize(asset_directory, logger)
      @asset_directory = asset_directory
      @logger = logger
    end

    def do_it
      debomed_file_names = []
      # find all css files and remove the BOM from any that have it...
      all_css_files.each do |css_file_name|
        if remove_bom_from(css_file_name)
          logger.info "Removed BOM from #{css_file_name}"
          debomed_file_names << css_file_name
        else
          logger.debug "No BOM found in #{css_file_name}"
        end
      end
      # ...then remove the BOM from the gzipped versions of those files
      debomed_file_names.each do |debomed_file_name|
        if remove_bom_from_gzipped_version_of(debomed_file_name)
          logger.info "Removed BOM from #{debomed_file_name}.gz"
        else
          logger.debug "No BOM to remove as #{debomed_file_name}.gz not present"
        end
      end
    end

  private

    attr_reader :asset_directory, :logger

    def all_css_files
      @all_css_files ||= Dir[File.join(asset_directory, '**', '*.css')]
    end

    def remove_bom_from(file_name)
      # use binread / binwrite to preserve any encoding
      file_contents = File.binread(file_name)
      if file_contents.bytes[0..2] == [0xEF, 0xBB, 0xBF]
        File.binwrite(file_name, file_contents[3..-1])
        true
      else
        false
      end
    end

    def remove_bom_from_gzipped_version_of(file_name)
      # re-write the gziped version using sprockets own gzipper
      if File.exist?("#{file_name}.gz")
        # TODO: this might be a private API we're using so there's danger
        # this'll go away
        asset = DeBomedCssAsset.new(file_name)
        Sprockets::Utils::Gzip.new(asset).compress(file_name)
        true
      else
        false
      end
    end
  end
end
