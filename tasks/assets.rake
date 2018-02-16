namespace :assets do

  task :require do
    $:.unshift File.expand_path('../../lib', __FILE__)
    require 'easycast'
    require 'uglifier'
    include Easycast
  end

  task :prepare => :require do
    FileUtils.mkdir_p WEBASSETS_FOLDER
  end

  desc 'compile assets'
  task :compile => [:prepare, :clean, :compile_js, :compile_css]

  desc 'compile javascript assets'
  task :compile_js => :prepare do
    Controller::Assets['vendor.js'].write_to(WEBASSETS_FOLDER/"vendor-#{VERSION}.min.js")
    Controller::Assets.js_compressor = Uglifier.new(mangle: true)
    Controller::Assets['easycast.js'].write_to(WEBASSETS_FOLDER/"easycast-#{VERSION}.min.js")

    puts "successfully compiled js assets"
  end

  desc 'compile css assets'
  task :compile_css => :prepare do
    Controller::Assets['vendor.css'].write_to(WEBASSETS_FOLDER/"vendor-#{VERSION}.min.css")
    Controller::Assets['easycast.css'].write_to(WEBASSETS_FOLDER/"easycast-#{VERSION}.min.css")
    puts "successfully compiled css assets"
  end

  desc 'Cleans generated assets'
  task :clean => :require do
    FileUtils.rm_rf WEBASSETS_FOLDER
  end

end
