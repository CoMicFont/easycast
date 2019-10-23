module Easycast
  class Walk

    def initialize(config, linearization = nil, state = nil, repeat = nil)
      @config = config
      @linearization = linearization || linearize_nodes([], config.nodes, 0)
      @state = state || find_next(-1)
      raise "illegal state" unless @state
      @repeat = repeat || @linearization[@state][:repeat] || 1
      # Class invariant, the current state is the index of the current node
      raise "illegal state" unless @linearization[@state][:index] == @state
    end
    attr_reader :config, :linearization, :state

    def current_scene
      config.scene_by_id(linearization[state][:scene])
    end

    def next(auto = false)
      if (auto == true && @repeat > 1) then
        Walk.new(config, linearization, state, @repeat - 1)
      else
        next_state = find_next(state)
        repeat = linearization[next_state][:repeat]
        Walk.new(config, linearization, next_state, repeat)
      end
    end

    def previous
      prev_state = find_previous(state)
      repeat = linearization[prev_state][:repeat]
      Walk.new(config, linearization, prev_state, repeat)
    end

    def jump(nth)
      target_state = find_next((nth-1) % linearization.size)
      repeat = linearization[target_state][:repeat]
      Walk.new(config, linearization, target_state, repeat)
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
end # module Easycast
