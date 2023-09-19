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
      also_reload 'lib/easycast/assers/*.rb'
      also_reload 'lib/easycast/controller.rb'
      enable :reloader
    end

  ### Scenes configuration

    def self.load_config(folder = Easycast.current_scenes_folder)
      # load the config and check it
      set :config, Config.load(folder).check!.ensure_assets!
      # initialize the walk
      set :tour, FullTour.new(config, nil, settings.scheduler)
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
    set :scheduler, nil
    load_config

  ### Station configurations

    get '/stations/:station/config' do |station|
      s = settings.config.station_by_name(station, true)
      not_found unless s
      content_type :yaml
      s.to_h.to_yaml
    end

    get '/stations/:station/displays-envvar' do |station|
      s = settings.config.station_by_name(station, true)
      not_found unless s
      content_type "text/plain"
      s.displays_envvar
    end

  ### Display and remote control

    get "/" do
      content_type :html
      serve Views::Home.new(settings.config, settings.tour.to_state)
    end

    get "/display/:i" do |i|
      content_type :html
      serve Views::Display.new(settings.config, settings.tour.to_state, i.to_i)
    end

    get '/splash' do
      content_type :html
      serve Views::Splash.new, Views::SplashLayout
    end

    get '/remote' do
      content_type :html
      serve Views::Remote.new(settings.config, settings.tour.to_state)
    end

    get '/doors' do
      content_type :html
      serve Views::Doors.new(settings.config, settings.tour.to_state)
    end

    get '/qr-codes' do
      content_type :html
      serve Views::QrCodes.new(settings.config, settings.tour.to_state)
    end

  ### Source switcher

  get '/switcher' do
    content_type :html
    serve Views::Switcher.new(settings.config, settings.tour.to_state)
  end

  post '/switch/:code' do |code|
    folder = Easycast.each_scenes_folder.find{|f|
      Digest::SHA1.hexdigest(f.expand_path.to_s) == code
    }
    if folder
      puts "Setting scenes folder to #{folder}"
      state_change{ settings.tour.pause } unless settings.tour.paused?
      Easycast.set_current_scenes_folder(folder)
      settings.load_config
      settings.notify_state
    end
    content_type :json
    settings.tour.to_external_state.to_json
  end

  ### Distant execution of actions

    get '/ssh-public-key' do
      send_file "#{EASYCAST_USER_HOME}/.ssh/id_ed25519.pub"
    end

    post '/restart' do
      distant_exec("restart-displays")
    end

    post '/reboot' do
      distant_exec("reboot")
    end

    def distant_exec(cmd)
      settings.config.each_station.map{|station|
        ip = "easycast-#{station[:name]}.local"
        user = EASYCAST_USER
        LOGGER.info("Sending `#{cmd}` to #{ip}")
        LOGGER.debug(`ssh -i #{EASYCAST_USER_HOME}/.ssh/id_ed25519 -o StrictHostKeyChecking=no #{user}@#{ip} #{EASYCAST_USER_HOME}/easycast/bin/#{cmd} >/dev/null </dev/null 2>&1 &`)
      }.join("\n")
    end

  ### Walk

    post '/tour/subtour/:i' do |i|
      set_tour settings.tour.sub_tour(i.to_i)
      serve_nothing
    end

    post '/tour/jump/:i' do |i|
      set_tour settings.tour.jump(i.to_i)
      serve_nothing
    end

    post '/tour/next' do
      set_tour settings.tour.next
      serve_nothing
    end

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

  ### Scheduler

    post '/video/pause' do
      notify_video('pause')
      204
    end

    post '/video/play' do
      notify_video('play')
      204
    end

    post '/video/backward' do
      notify_video('backward')
      204
    end

    post '/video/forward' do
      notify_video('forward')
      204
    end

    def notify_video(command)
      unless settings.tour.paused?
        settings.tour.pause
      end
      settings.notify(type: 'video', detail: { command: command })
      204
    end

  ### Controller tour

    def self.state_change(&bl)
      old_ext_state = settings.tour.to_external_state
      bl.call
      new_ext_state = settings.tour.to_external_state
      notify_state(new_ext_state) if (old_ext_state != new_ext_state)
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

    get '/state' do
      content_type :json
      settings.tour.to_external_state.to_json
    end

    def self.notify_state(state = settings.tour.to_external_state)
      notify(type: 'state', detail: state)
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

  private

    def serve(view, layout = nil)
      settings.load_config if has_error? || settings.config.outdated?
      if has_error?
        serve_error
      elsif layout
        layout.new(view).render
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
require_relative 'views/switcher'
require_relative 'views/doors'
require_relative 'views/error'
require_relative 'views/splash_layout'
require_relative 'views/splash'
require_relative 'views/qr_codes'
