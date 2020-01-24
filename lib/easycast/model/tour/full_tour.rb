module Easycast
  class FullTour < Tour

    def initialize(config, walk = nil, scheduler = nil)
      @config = config
      @walk = walk || Walk.new(config)
      @scheduler = scheduler || Rufus::Scheduler.new
    end
    attr_reader :config, :walk, :scheduler

    # subtour handling

    def sub_tour(i)
      SubTour.new(self, @walk.node_at(i)).resume
    end

    # walk handling

    def home(*args)
      FullTour.new(@config, @walk.home(*args), @scheduler)
    end

    def next(*args)
      FullTour.new(@config, @walk.next(*args), @scheduler)
    end

    def previous(*args)
      FullTour.new(@config, @walk.previous(*args), @scheduler)
    end

    def jump(i)
      FullTour.new(@config, @walk.jump(i), @scheduler)
    end

  end # class Tour
end # module Easycast
