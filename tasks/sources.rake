namespace :sources do

  task :check => :require do
    config = Config.load(SCENES_FOLDER)
    config.check!
  end

  task :ensure => :require do
    config = Config.load(SCENES_FOLDER)
    config.check!
    config.ensure_assets!
  end

end
