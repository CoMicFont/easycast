module Easycast
  module Views
    class Remote
      class Node < View

        def initialize(config, node, walk)
          super(config)
          @node = node
          @walk = walk
        end
        attr_reader :config, :node, :walk

        def name
          node[:scene] ? config.scene_by_id(node[:scene]).name : node[:name]
        end

        def index
          node[:index]
        end

        def css_class
          index == walk.state ? "active" : ""
        end

        def subtree
          Floor.new(config, node[:children], walk).render if node[:children]
        end

      end
    end
  end
end
