module Easycast
  class Controller < Sinatra::Base
    set :raise_errors, true
    set :show_exceptions, false

  ### Reloader configuration

    if DEVELOPMENT_MODE
      register Sinatra::Reloader
      also_reload 'lib/easycast/views/*.rb'
      also_reload 'lib/easycast/views/remote/*.rb'
      also_reload 'lib/easycast/model/*.rb'
      enable :reloader
    end

  ### Scenes configuration

    def self.load_config
      set :config, Config.load(SCENES_FOLDER)
      set :walk, Walk.new(config)
      set :load_error, nil
      set :scheduler, Rufus::Scheduler.new
    rescue => ex
      LOGGER.fatal(ex.message)
      set :config, nil
      set :walk, nil
      set :load_error, ex
      set :scheduler, nil
    end
    load_config

  ### Display and remote control

    #
    # Returns the .html file of the root page, allowing
    # to choose a display
    #
    get "/" do
      content_type :html
      serve Views::Home.new(settings.config, get_state)
    end

    ##
    ## Returns the .html file of the n-th display
    ##
    get "/display/:i" do |i|
      content_type :html
      serve Views::Display.new(settings.config, get_state, i.to_i)
    end

    ##
    ## Returns the .html file of the remote
    ##
    get '/remote' do
      content_type :html
      serve Views::Remote.new(settings.config, get_state)
    end

    ##
    ## Force all displays to refresh
    ##
    post '/refresh' do
      [ 'easycast', 'raspberrypi' ].map{|ip|
        `ssh pi@#{ip} /home/pi/easycast/bin/refresh-display`
      }.join("\n")
    end

  ### Walk

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

  ### Scheduler

    def scheduler
      settings.scheduler
    end

    scheduler.interval(settings.config.animation[:frequency]) do
      settings.walk = settings.walk.next(true)
    end

    scheduler.pause unless settings.config.animation[:autoplay]

    post '/scheduler/pause' do
      scheduler.pause unless scheduler.paused?
      204
    end

    post '/scheduler/resume' do
      scheduler.resume if scheduler.paused?
      204
    end

    post '/scheduler/toggle' do
      if scheduler.paused?
        scheduler.resume
        201
      else
        scheduler.pause
        204
      end
    end

  ### Controller state

    def get_state
      OpenStruct.new({
        config: settings.config,
        walk: settings.walk,
        scheduler: settings.scheduler
      })
    end

    ##
    ## Returns the current state of the controller, i.e.
    ## current node and scheduler state.
    ##
    get '/state' do
      content_type :json
      state = get_state
      {
        walkIndex: state.walk.state,
        paused: state.scheduler.paused?
      }.to_json
    end

  private

    def serve(view)
      if DEVELOPMENT_MODE
        settings.config = Config.load(SCENES_FOLDER)
        settings.walk = Walk.new(settings.config, nil, settings.walk.state)
      end
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
