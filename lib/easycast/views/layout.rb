module Easycast
  module Views
    #
    # Main view for all pages, providing the global context for title
    # available scenes, current one, etc.
    #
    class Layout < Mustache

      def body_class
        @body_class
      end

      def title
        "Easycast | #{subtitle}"
      end

      def scenes
        @scenes
      end

      def scene_index
        @scene_index
      end

      def current_scene
        scenes.scene(scene_index)
      end

    end
  end
end
