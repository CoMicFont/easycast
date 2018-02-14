module Easycast
  class Walk

    def initialize(config, linearization = nil, state = nil)
      @config = config
      @linearization = linearization || linearize_nodes([], config.nodes, 0)
      @state = state || find_next(-1)

      # Class invariant, the current state is the index of the current node
      raise "illegal state" unless @linearization[@state][:index] == @state
    end
    attr_reader :config, :linearization, :state

    def current_scene
      config.scene_by_id(linearization[state][:scene])
    end

    def next
      Walk.new(config, linearization, find_next(state))
    end

    def previous
      Walk.new(config, linearization, find_previous(state))
    end

    def jump(nth)
      Walk.new(config, linearization, find_next((nth-1) % linearization.size))
    end

  private

    def find_next(from = @state)
      n = linearization.size
      n.times do |i|
        j = (from+i+1) % n
        return j if linearization[j][:scene]
      end
      raise NotImplementedError, "At least one scene is required"
    end

    def find_previous(from = @state)
      n = linearization.size
      n.times do |i|
        j = (from-i-1) % n
        return j if linearization[j][:scene]
      end
      raise NotImplementedError, "At least one scene is required"
    end

    def linearize_nodes(acc, remaining_nodes, i)
      if remaining_nodes.empty? then acc
      else
        node, *tail = *remaining_nodes
        children = node[:children] ? node[:children] : []
        linearize_nodes(acc + [node], children + tail, i+1)
      end
    end

  end # class Walk
end # module Easycase
