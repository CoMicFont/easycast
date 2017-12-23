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

      def config
        @config
      end

      def scenes
        config.scenes.each_with_index.map{|s, i|
          s.merge({
            index: i,
            active: (i == scene_index),
            css_class: (i == scene_index ? "active" : "")
          })
        }
      end

      def scene_index
        @scene_index
      end

      def current_scene
        config.scene(scene_index)
      end

    end
  end
end
