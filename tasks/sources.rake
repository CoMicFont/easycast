namespace :sources do

  desc "Checks the scenes folder"
  task :check => :require do
    config = Config.load(SCENES_FOLDER)
    config.check!
  end

  desc "Cleans the generated assets"
  task :clean => :require do
    `rm -rf #{SCENES_FOLDER/'assets'}/_*`
  end

  desc "Checks the scenes folder and ensures all assets are generated"
  task :ensure => :require do
    config = Config.load(SCENES_FOLDER)
    config.check!
    config.ensure_assets!
  end

end
