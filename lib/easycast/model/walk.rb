module Easycast
  #
  # Implements Walk abstraction of the tree structure captured by the scenes
  # config.
  #
  # This class taks the config as input, and internally keeps a linearization
  # of the tree (according to a DFS), a current state (index in the
  # linearization) and a repeat counter for handling repeated scene nodes.
  #
  # It provides a behavioral API allowing to move to next/previous nodes (or
  # repeated steps of a node), in an immutable way (that is, each move simply
  # returns another Walk instance).
  #
  class Walk

    def initialize(config, linearization = nil, state = nil, repeat = nil,
      start_state = nil, end_state = nil)
      @config = config
      @linearization = linearization || Walk.linearize(config.nodes)
      @state = state || find_next(-1)
      @start_state = start_state || find_next(-1)
      @end_state = end_state || find_previous(0)
      raise "illegal state" unless @state
      @repeat = repeat || @linearization[@state][:repeat] || 1
      # Class invariant, the current state is the index of the current node
      raise "illegal state" unless @linearization[@state][:index] == @state
    end
    attr_reader :config, :linearization, :state

    def self.linearize(nodes)
      _linearize([], nodes, 0)
    end

    def self._linearize(acc, remaining_nodes, i)
      if remaining_nodes.empty? then acc
      else
        node, *tail = *remaining_nodes
        children = node[:children] ? node[:children] : []
        _linearize(acc + [node], children + tail, i+1)
      end
    end

    # Returns the scene corresponding to the current Walk state
    def current_scene
      config.scene_by_id(linearization[state][:scene])
    end

    def is_at_begin?
      @state == @start_state
    end

    def is_at_end?
      @state == @end_state
    end

    def home
      repeat = linearization[@start_state][:repeat]
      Walk.new(config, linearization, @start_state, repeat, @start_state, @end_state)
    end

    # Move to the next Walk state. When `auto` is true, handle repeated nodes,
    # otherwise immediately jump to the next one.
    def next(auto = false)
      if (auto == true && @repeat > 1) then
        Walk.new(config, linearization, state, @repeat - 1, @start_state, @end_state)
      else
        next_state = find_next(state)
        repeat = linearization[next_state][:repeat]
        Walk.new(config, linearization, next_state, repeat, @start_state, @end_state)
      end
    end

    # Move to the previous Walk state. No `auto` supported is implemented yet.
    def previous
      prev_state = find_previous(state)
      repeat = linearization[prev_state][:repeat]
      Walk.new(config, linearization, prev_state, repeat, @start_state, @end_state)
    end

    # Jump to the nth Walk state.
    def jump(nth)
      target_state = find_next((nth-1) % linearization.size)
      repeat = linearization[target_state][:repeat]
      Walk.new(config, linearization, target_state, repeat, @start_state, @end_state)
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

  end # class Walk
end # module Easycast
