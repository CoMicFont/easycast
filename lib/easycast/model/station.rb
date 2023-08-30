module Easycast
  #
  # Captures a given station, as described in a scenes.yml file.
  #
  # A station is a device having behavioral roles and optional displays.
  #
  class Station < OpenStruct

    def initialize(data, config = nil)
      super(data)
      @config = config
    end
    attr_reader :config

    def self.dress(data)
      new Config::SCHEMA['Station'].dress(data)
    end

    def each_display(&block)
      (self[:displays] || []).each(&block)
    end

    def easycast_user_home
      EASYCAST_USER_HOME
    end

    def easycast_user
      EASYCAST_USER
    end

    def displays_envvar
      each_display
        .map{|d| "#{d[:identifier]}-#{d[:position]}-#{d[:size]}" }
        .join(';')
    end

  end # class Station
end # module Easycast
