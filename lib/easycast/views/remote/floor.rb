module Easycast
  module Views
    class Remote
      class Floor < View

        def initialize(config, nodes, walk)
          super(config)
          @nodes = nodes.map{|n| Node.new(config, n, walk) }
        end
        attr_reader :nodes

      end
    end
  end
end
