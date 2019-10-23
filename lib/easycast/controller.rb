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
      also_reload 'lib/easycast/controller.rb'
      enable :reloader
    end

  ### Scenes configuration

    def self.load_config(folder = SCENES_FOLDER)
      # load the config and check it
      set :config, Config.load(folder).check!.ensure_assets!
      # initialize the walk
      set :walk, Walk.new(config)
      # create the scheduler and configure it
      set :scheduler, Rufus::Scheduler.new
      scheduler.interval(config.animation[:frequency]) do
        set_walk walk.next(true)
      end
      scheduler.pause unless config.animation[:autoplay]
      # mark that everything is fine!
      puts "Started successfull on #{folder}"
      set :load_error, nil
    rescue => ex
      set :config, nil
      set :walk, nil
      set :scheduler, nil
      set :load_error, ex
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
    rescue => ex
      serve_error(ex)
    end

    ##
    ## Returns the .html file of the n-th display
    ##
    get "/display/:i" do |i|
      content_type :html
      serve Views::Display.new(settings.config, get_state, i.to_i)
    rescue => ex
      serve_error(ex)
    end

    ##
    ## Returns the .html file of the remote
    ##
    get '/remote' do
      content_type :html
      serve Views::Remote.new(settings.config, get_state)
    rescue => ex
      serve_error(ex)
    end

    ##
    ## Force all displays to refresh
    ##
    post '/refresh' do
      distant_exec("refresh-display")
    end

    ##
    ## Force all displays to restart
    ##
    post '/restart' do
      distant_exec("restart-display")
    end

    ##
    ## Force all displays to restart
    ##
    post '/reboot' do
      distant_exec("reboot-display")
    end

    def distant_exec(cmd)
      [ 'easyslave', 'easycast' ].map{|ip|
        LOGGER.info("Sending `#{cmd}` to #{ip}")
        LOGGER.debug(`ssh -i /home/pi/.ssh/id_rsa -o StrictHostKeyChecking=no pi@#{ip} /home/pi/easycast/bin/#{cmd}`)
      }.join("\n")
    end

  ### Walk

    ##
    ## Updates the current walk state to the i-th node
    ##
    post '/walk/state/:i' do |i|
      set_walk settings.walk.jump(i.to_i)
      serve_nothing
    end

    ##
    ## Moves the current walk state to the next scene
    ##
    post '/walk/next' do
      set_walk settings.walk.next
      serve_nothing
    end

    ##
    ## Moves the current walk state to the previous scene
    ##
    post '/walk/previous' do
      set_walk settings.walk.previous
      serve_nothing
    end

  ### Scheduler

    def scheduler
      settings.scheduler
    end

    post '/scheduler/pause' do
      unless scheduler.paused?
        settings.state_change{ scheduler.pause }
      end
      204
    end

    post '/scheduler/resume' do
      if scheduler.paused?
        settings.state_change{ scheduler.resume }
      end
      204
    end

    post '/scheduler/toggle' do
      if scheduler.paused?
        settings.state_change{ scheduler.resume }
        201
      else
        settings.state_change{ scheduler.pause }
        204
      end
    end

  ### Controller state

    def self.get_external_state
      {
        walkIndex: self.walk.state,
        paused: self.scheduler.paused?
      }
    end

    def get_external_state
      settings.get_external_state
    end

    def get_state
      OpenStruct.new({
        config: settings.config,
        walk: settings.walk,
        scheduler: settings.scheduler
      })
    end

    def self.state_change(&bl)
      old_ext_state = get_external_state
      bl.call
      new_ext_state = get_external_state
      notify(new_ext_state) if (old_ext_state != new_ext_state)
    end

    def self.set_walk(walk)
      state_change{ settings.walk = walk }
    end

    def set_walk(walk)
      settings.set_walk(walk)
    end

    ##
    ## Returns the current state of the controller, i.e.
    ## current node and scheduler state.
    ##
    get '/state' do
      content_type :json
      get_external_state.to_json
    end

  ### Streaming approach

    set connections: []

    get '/notifications', provides: 'text/event-stream' do
      stream :keep_open do |out|
        settings.connections << out
        out.callback { settings.connections.delete(out) }
      end
    end

    def self.notify(state)
      settings.connections.each do |out|
        out << "data: " << state.to_json << "\n\n"
      end
    end

    def notify(state)
      settings.notify(state)
    end

  private

    def serve(view)
      settings.load_config if has_error?
      if has_error?
        serve_error
      elsif env['HTTP_ACCEPT'] == "application/vnd.easycast.display+html"
        Views::Partial.new(view).render
      else
        Views::Layout.new(view).render
      end
    end

    def serve_error(ex = settings.load_error)
      view = Views::Error.new(settings.config, settings.load_error || ex)
      Views::Layout.new(view).render.tap{
        settings.load_config if has_error?
      }
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
require_relative 'views/partial'
require_relative 'views/home'
require_relative 'views/display'
require_relative 'views/remote'
require_relative 'views/error'
