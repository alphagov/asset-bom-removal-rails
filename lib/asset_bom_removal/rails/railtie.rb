module AssetBomRemoval
  module Rails
    class Railtie < ::Rails::Railtie
      rake_tasks do
        load 'tasks/asset_bom_removal-rails.rake'
        Rake::Task['assets:precompile'].enhance do
          Rake::Task['assets:bom_removal'].invoke
        end
      end
    end
  end
end
