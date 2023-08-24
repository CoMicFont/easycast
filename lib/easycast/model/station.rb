module Easycast
  #
  # Captures a given station, as described in a scenes.yml file.
  #
  # A station is a device having behavioral roles and optional displays.
  #
  class Station < OpenStruct

    def initialize(data, config)
      super(data)
      @config = config
    end
    attr_reader :config

  end # class Station
end # module Easycast
