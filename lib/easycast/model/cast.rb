module Easycast
  #
  # A Cast is the configuration of a given display within a scene.
  #
  # Basically, a cast is a collection of assets put on top of each others.
  #
  class Cast < OpenStruct

    def assets
      self[:assets].map{|a| Asset.for(a) }
    end

  end # class Cast
end # module Easycast
