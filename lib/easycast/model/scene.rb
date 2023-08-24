module Easycast
  #
  # Captures a given scene, as described in a scenes.yml file.
  #
  # A scene provides a cast for each available displays.
  #
  class Scene < OpenStruct

    def initialize(data, config)
      super(data)
      @config = config
    end
    attr_reader :config

    def ensure_assets!
      _cast.each do |c|
        c.ensure_assets!
      end
    end

    #
    # Returns the case to use for a given display.
    #
    # @pre display_index >= 0
    # @pre display_index < number of available displays
    #
    def cast_at(display_index)
      _cast.find{|c| c[:display] == display_index } || empty_cast(display_index)
    end

    def empty_cast(display_index)
      Cast.new({
        display: display_index,
        remote: false,
        assets: [],
      }, config)
    end

  private

    def _cast
      @_cast ||= cast.map{|c| Cast.new(c, config) }
    end

  end # class Scene
end # module Easycast
