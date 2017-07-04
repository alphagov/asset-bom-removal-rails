namespace :assets do
  task bom_removal: :environment do
    require 'asset_bom_removal/bom_remover'

    if Dir.exist?(Rails.application.assets_manifest.directory)
      AssetBomRemoval::BomRemover.new(Rails.application.assets_manifest.directory, Rails.logger).do_it
    else
      Rails.logger.info("Asset directory not present.  Doing nothing.")
    end
  end
end
