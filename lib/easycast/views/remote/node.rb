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

        def css_class
          index == walk.state ? "node-#{index} active" : "node-#{index}"
        end

        def subtree
          Floor.new(config, state, node[:children]).render if node[:children]
        end

      end
    end
  end
end
