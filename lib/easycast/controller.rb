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

    ### Mustache configuration

    register Mustache::Sinatra
    set :mustache, {
      :templates => Path.dir/("templates"),
      :views => Path.dir/("views"),
      :namespace => Easycast
    }

    ### Reloader configuration

    register Sinatra::Reloader
    also_reload 'lib/easycast/views/*.rb'
    also_reload 'lib/easycast/model/*.rb'
    enable :reloader

    ### Cache configuration

    use Rack::Nocache

    ### Scenes configuration

    set :scene_index, 0

    def self.load_config
      set :config, Config.load(SCENES_FOLDER)
      set :load_error, nil
    rescue => ex
      set :config, nil
      set :load_error, ex
    end
    load_config

    ### Routes

    #
    # Returns the .html file of the root page, allowing
    # to choose a display
    #
    get "/" do
      @body_class = "home"
      content_type :html
      serve :home
    end

    ##
    ## Returns the .html file of the n-th display
    ##
    get "/display/:i" do |i|
      @display_index = i.to_i
      @body_class = "display"
      content_type :html
      serve :display
    end

    ##
    ## Returns the .html file of the remote
    ##
    get '/remote' do
      content_type :html
      @body_class = "remote"
      serve :remote
    end

    ##
    ## Returns the index of the current scene, in plain text
    ##
    get '/scene' do
      content_type 'text/plain'
      settings.scene_index.to_s
    end

    ##
    ## Updates the current scene to the i-th
    ##
    post '/scene/:i' do |i|
      settings.scene_index = i.to_i
      serve_nothing
    end

  private

    def serve(view, data = {})
      settings.load_config
      if has_error?
        @body_class = "error"
        @load_error = settings.load_error
        mustache(:error)
      else
        @config = settings.config
        @scene_index = settings.scene_index
        mustache(view)
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
require_relative 'views/layout'
require_relative 'views/home'
require_relative 'views/display'
require_relative 'views/remote'
require_relative 'views/error'
