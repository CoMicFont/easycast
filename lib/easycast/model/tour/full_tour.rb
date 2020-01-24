module Easycast
  class FullTour < Tour

    def initialize(config, walk = nil, scheduler = nil)
      @config = config
      @walk = walk || Walk.new(config)
      @scheduler = scheduler || Rufus::Scheduler.new
    end
    attr_reader :config, :walk, :scheduler

    # walk handling

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
