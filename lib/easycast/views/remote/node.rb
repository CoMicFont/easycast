module Easycast
  module Views
    class Remote
      class Node < View

        def initialize(config, state, node)
          super(config, state)
          @node = node
        end
        attr_reader :config, :node

        def name
          node[:scene] ? config.scene_by_id(node[:scene]).name : node[:name]
        end

        def index
          node[:index]
        end

        def video
          return false if node[:children]

          scene = config.scene_by_id(node[:scene])
          scene.has_video?
        end

        def css_class
          clazz = "node-#{index}"
          clazz << " active" if index == walk.state
          clazz << " video" if video
          clazz << " collapsable" if node[:children]
          clazz << " dynamic" unless node[:children]
          clazz
        end

        def subtree
          Floor.new(config, state, node[:children]).render if node[:children]
        end

      end
    end
  end
end
