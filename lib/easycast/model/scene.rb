module Easycast
  #
  # Captures a given scene, as described in a scenes.yml file.
  #
  # A scene provides a cast for each available displays.
  #
  class Scene < OpenStruct

    #
    # Returns the case to use for a given display.
    #
    # @pre display_index >= 0
    # @pre display_index < number of available displays
    #
    def cast_at(display_index)
      Cast.new self.cast.find{|c| c[:display] == display_index }
    end

  end # class Scene
end # module Easycast
