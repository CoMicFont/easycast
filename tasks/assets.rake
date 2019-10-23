namespace :assets do

  task :prepare => :require do
    require 'easycast/assets'
    FileUtils.mkdir_p WEBASSETS_FOLDER
  end

  desc 'compile assets'
  task :compile => [:prepare, :clean, :compile_js, :compile_css]

  desc 'compile javascript assets'
  task :compile_js => :prepare do
    Easycast::Assets::SprocketsAssets['vendor.js'].write_to(WEBASSETS_FOLDER/"vendor-#{VERSION}.min.js")
    Easycast::Assets::SprocketsAssets.js_compressor = Uglifier.new(mangle: true)
    Easycast::Assets::SprocketsAssets['easycast.js'].write_to(WEBASSETS_FOLDER/"easycast-#{VERSION}.min.js")
    puts "successfully compiled js assets"
  end

  desc 'compile css assets'
  task :compile_css => :prepare do
    Easycast::Assets::SprocketsAssets['vendor.css'].write_to(WEBASSETS_FOLDER/"vendor-#{VERSION}.min.css")
    Easycast::Assets::SprocketsAssets['easycast.css'].write_to(WEBASSETS_FOLDER/"easycast-#{VERSION}.min.css")
    puts "successfully compiled css assets"
  end

  desc 'Cleans generated assets'
  task :clean => :require do
    FileUtils.rm_rf WEBASSETS_FOLDER
  end

end
