module Easycast
  #
  # Captures a given scene, as described in a scenes.yml file.
  #
  # A scene provides a cast for each available displays.
  #
  class Scene < OpenStruct

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
      _cast.find{|c| c[:display] == display_index }
    end

  private

    def _cast
      @_cast ||= cast.map{|c| Cast.new(c) }
    end

  end # class Scene
end # module Easycast
