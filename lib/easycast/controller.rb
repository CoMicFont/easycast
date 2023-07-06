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
      set :tour, FullTour.new(config)
      # install scheduler and configure it
      tour.interval(config.animation[:frequency]) do
        set_tour tour.next(true)
      end
      tour.pause unless config.animation[:autoplay]
      # mark that everything is fine!
      puts "Config successfull (re)loaded #{folder}"
      set :load_error, nil
    rescue => ex
      puts ex.message
      puts ex.backtrace.join("\n")
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
      serve Views::Home.new(settings.config, settings.tour.to_state)
    end

    ##
    ## Returns the .html file of the n-th display
    ##
    get "/display/:i" do |i|
      content_type :html
      serve Views::Display.new(settings.config, settings.tour.to_state, i.to_i)
    end

    ##
    ## Returns the .html file of the remote
    ##
    get '/remote' do
      content_type :html
      serve Views::Remote.new(settings.config, settings.tour.to_state)
    end

    ##
    ## Returns the .html file of the doors
    ##
    get '/doors' do
      content_type :html
      serve Views::Doors.new(settings.config, settings.tour.to_state)
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
      [ 'easyslave', 'easymaster' ].map{|ip|
        LOGGER.info("Sending `#{cmd}` to #{ip}")
        LOGGER.debug(`ssh -i /home/pi/.ssh/id_rsa -o StrictHostKeyChecking=no pi@#{ip} /home/pi/easycast/bin/#{cmd}`)
      }.join("\n")
    end

  ### Walk

    ##
    ## Start a subtour on the i-th node
    ##
    post '/tour/subtour/:i' do |i|
      set_tour settings.tour.sub_tour(i.to_i)
      serve_nothing
    end

    ##
    ## Updates the current walk tour to the i-th node
    ##
    post '/tour/jump/:i' do |i|
      set_tour settings.tour.jump(i.to_i)
      serve_nothing
    end

    ##
    ## Moves the current walk tour to the next scene
    ##
    post '/tour/next' do
      set_tour settings.tour.next
      serve_nothing
    end

    ##
    ## Moves the current walk tour to the previous scene
    ##
    post '/tour/previous' do
      set_tour settings.tour.previous
      serve_nothing
    end

  ### Scheduler

    post '/scheduler/pause' do
      state_change{ settings.tour.pause } unless settings.tour.paused?
      204
    end

    post '/scheduler/resume' do
      state_change{ settings.tour.resume } if settings.tour.paused?
      204
    end

    post '/scheduler/toggle' do
      if settings.tour.paused?
        state_change{ settings.tour.resume }
        201
      else
        state_change{ settings.tour.pause }
        204
      end
    end

  ### Controller tour

    def self.state_change(&bl)
      old_ext_state = settings.tour.to_external_state
      bl.call
      new_ext_state = settings.tour.to_external_state
      notify(new_ext_state) if (old_ext_state != new_ext_state)
    end

    def state_change(*args, &bl)
      settings.state_change(*args, &bl)
    end

    def self.set_tour(tour)
      state_change{ settings.tour = tour }
    end

    def set_tour(*args, &bl)
      settings.set_tour(*args, &bl)
    end

    ##
    ## Returns the current state of the controller, i.e.
    ## current node and scheduler state.
    ##
    get '/state' do
      content_type :json
      settings.tour.to_external_state.to_json
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
      settings.load_config if has_error? || settings.config.outdated?
      if has_error?
        serve_error
      elsif env['HTTP_ACCEPT'] == "application/vnd.easycast.display+html"
        Views::Partial.new(view).render
      else
        Views::Layout.new(view).render
      end
    rescue => ex
      serve_error(ex)
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
require_relative 'views/doors'
require_relative 'views/error'
