module Easycast
  module Views
    class Remote
      class Floor < View

        def initialize(config, state, nodes)
          super(config, state)
          @nodes = nodes.map{|n| Node.new(config, state, n) }
        end
        attr_reader :nodes

      end
    end
  end
end
