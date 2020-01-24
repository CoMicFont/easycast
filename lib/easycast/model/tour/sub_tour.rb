module Easycast
  class SubTour < Tour

    def initialize(parent, root, walk = nil)
      raise ArgumentError, "Children required" if (root[:children] || []).empty?
      @parent = parent
      @root = root
      @walk = walk || Walk.new(parent.config, Walk.linearize(root[:children]))
    end
    attr_reader :parent, :root

    def config
      parent.config
    end

    attr_reader :walk

    def scheduler
      parent.scheduler
    end

    # walk handling

    def sub_tour(i)
      parent.sub_tour(i)
    end

    def home(*args)
      SubTour.new(@config, root, walk.home(*args))
    end

    def next(*args)
      next_walk = walk.next(*args)
      if next_walk.is_at_begin?
        parent.home.pause
      else
        SubTour.new(parent, root, next_walk)
      end
    end

    def previous(*args)
      prev_walk = walk.previous(*args)
      if prev_walk.is_at_end?
        parent.home.pause
      else
        SubTour.new(parent, root, prev_walk)
      end
    end

    def jump(i)
      SubTour.new(parent, root, walk.jump(i))
    end

    def to_external_state
      super.merge(doorIndex: root[:index])
    end

  end # class State
end # module Easycast
