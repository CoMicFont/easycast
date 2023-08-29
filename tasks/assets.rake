namespace :assets do

  task :prepare => :require do
    require 'easycast'
    require 'easycast/service'
    FileUtils.mkdir_p WEBASSETS_FOLDER
  end

  desc 'compile assets'
  task :compile => [:prepare, :clean, :compile_js, :compile_css, :compile_html]

  desc 'compile javascript assets'
  task :compile_js => :prepare do
    Easycast::SprocketsAssets['vendor.js'].write_to(WEBASSETS_FOLDER/"vendor-#{VERSION}.min.js")
    Easycast::SprocketsAssets.js_compressor = Uglifier.new(mangle: true)
    Easycast::SprocketsAssets['easycast.js'].write_to(WEBASSETS_FOLDER/"easycast-#{VERSION}.min.js")
    puts "successfully compiled js assets"
  end

  desc 'compile css assets'
  task :compile_css => :prepare do
    Easycast::SprocketsAssets['vendor.css'].write_to(WEBASSETS_FOLDER/"vendor-#{VERSION}.min.css")
    Easycast::SprocketsAssets['easycast.css'].write_to(WEBASSETS_FOLDER/"easycast-#{VERSION}.min.css")
    puts "successfully compiled css assets"
  end

  desc 'compile html assets'
  task :compile_html => :prepare do
    html = Easycast::Views::SplashLayout.new(Easycast::Views::Splash.new).render
    (WEBASSETS_FOLDER/"splash.html").write(html)
    puts "successfully compiled html assets"
  end

  desc 'Cleans generated assets'
  task :clean => :require do
    FileUtils.rm_rf WEBASSETS_FOLDER
  end

end
