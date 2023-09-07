namespace :sources do

  desc "Checks the scenes folder"
  task :check => :require do
    Easycast.each_scenes_folder do |scene_folder|
      puts "\n === Checking #{scene_folder}"
      config = Config.load(scene_folder)
      config.check!
    end
  end

  desc "Cleans the generated assets"
  task :clean => :require do
    Easycast.each_scenes_folder do |scene_folder|
      puts "\n === Cleaning #{scene_folder}"
      `rm -rf #{scene_folder/'assets'}/_*`
    end
  end

  desc "Checks the scenes folder and ensures all assets are generated"
  task :ensure => :require do
    Easycast.each_scenes_folder do |scene_folder|
      puts "\n === Ensuring all assets in #{scene_folder}"
      config = Config.load(scene_folder)
      config.check!
      config.ensure_assets!
    end
  end

end
