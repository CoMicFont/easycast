module Easycast
  class Controller < Sinatra::Base
    set :raise_errors, true
    set :show_exceptions, false

    ### Assets handling

    set :public_folder, SCENES_FOLDER/("assets")

    Assets = Sprockets::Environment.new
    Assets.append_path Path.dir/('webassets')
    Assets.css_compressor = :scss

    get "/webassets/*" do
      env["PATH_INFO"].sub!("/webassets", "")
      Assets.call(env)
    end

    get "/fonts/:font" do |f|
      send_file Path.dir/"webassets/fonts"/f
    end

    ### Reloader configuration

    register Sinatra::Reloader
    also_reload 'lib/easycast/views/*.rb'
    also_reload 'lib/easycast/views/remote/*.rb'
    also_reload 'lib/easycast/model/*.rb'
    enable :reloader

    ### Cache configuration

    use Rack::Nocache

    ### Scenes configuration

    def self.load_config
      set :config, Config.load(SCENES_FOLDER)
      set :walk, Walk.new(config)
      set :load_error, nil
    rescue => ex
      set :config, nil
      set :walk, nil
      set :load_error, ex
    end
    load_config

    ### Routes

    #
    # Returns the .html file of the root page, allowing
    # to choose a display
    #
    get "/" do
      content_type :html
      serve Views::Home.new(settings.config)
    end

    ##
    ## Returns the .html file of the n-th display
    ##
    get "/display/:i" do |i|
      content_type :html
      serve Views::Display.new(settings.config, i.to_i, settings.walk)
    end

    ##
    ## Returns the .html file of the remote
    ##
    get '/remote' do
      content_type :html
      serve Views::Remote.new(settings.config, settings.walk)
    end

    ##
    ## Returns the current state of the walk
    ##
    get '/walk/state' do
      content_type 'text/plain'
      settings.walk.state.to_s
    end

    ##
    ## Updates the current walk state to the i-th node
    ##
    post '/walk/state/:i' do |i|
      settings.walk = settings.walk.jump(i.to_i)
      serve_nothing
    end

    ##
    ## Moves the current walk state to the next scene
    ##
    post '/walk/next' do
      settings.walk = settings.walk.next
      serve_nothing
    end

    ##
    ## Moves the current walk state to the previous scene
    ##
    post '/walk/previous' do
      settings.walk = settings.walk.previous
      serve_nothing
    end

  private

    def serve(view)
      if has_error?
        Views::Error.new(settings.config, settings.load_error).render
      else
        Views::Layout.new(view).render
      end
    end

    def serve_nothing
      [ 204, {}, [] ]
    end

    def has_error?
      !!settings.load_error
    end

  end # class Controller
end # module Easycast
require_relative 'views/view'
require_relative 'views/layout'
require_relative 'views/home'
require_relative 'views/display'
require_relative 'views/remote'
require_relative 'views/error'
