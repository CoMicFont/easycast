task :check => :require do
  config = Config.load(SCENES_FOLDER)
  config.check!
  config.ensure_assets!
end
