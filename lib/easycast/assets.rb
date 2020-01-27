module Easycast
  class Assets < Sinatra::Base
    set :raise_errors, true
    set :show_exceptions, false

    ### Assets handling

    set :public_folder, SCENES_FOLDER/("assets")

    SprocketsAssets = Sprockets::Environment.new
    SprocketsAssets.append_path Path.dir/('webassets')
    SprocketsAssets.append_path SCENES_FOLDER/("assets")
    SprocketsAssets.css_compressor = :scss

    # These are only for development purpose. The assets used
    # in production are located in assets/webassets, are versionned
    # and can be cached. These ones cannot be put in cache.
    get "/webassets/*" do
      env["PATH_INFO"].sub!("/webassets", "")
      SprocketsAssets.call(env)
    end

    get "/fonts/:font" do |f|
      send_file Path.dir/"webassets/fonts"/f
    end

  end # class Assets
end # module Easycast
