module Easycast
  class Tour

    # scheduler handling

    def paused?
      scheduler.paused?
    end

    def pause
      scheduler.pause unless scheduler.paused?
      self
    end

    def resume
      scheduler.resume if scheduler.paused?
      self
    end

    def toggle
      paused? ? resume : pause
    end

    def interval(freq, &bl)
      scheduler.interval(freq, &bl)
      self
    end

    # dump handling

    def to_state
      OpenStruct.new({
        config: config,
        walk: walk,
        scheduler: scheduler
      })
    end

    def to_external_state
      {
        walkIndex: walk.state,
        paused: paused?
      }
    end

  end # class Tour
end # module Easycast
require_relative 'tour/full_tour'
