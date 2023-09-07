module Easycast
  #
  # A Cast is the configuration of a given display within a scene.
  #
  # Basically, a cast is a collection of assets put on top of each others.
  #
  class Cast < OpenStruct

    def initialize(data, config)
      super(data)
      @config = config
    end
    attr_reader :config

    # override ruby's display method
    def display
      self[:display]
    end

    def assets
      @assets ||= self[:assets].map{|a| Asset.for(self, a, config) }
    end

    def has_video?
      assets.any? {|asset|
        asset.is_a?(Asset::Video)
      }
    end

    def ensure_assets!
      assets.each do |a|
        a.ensure!
      end
    end

    def all_resources
      @all_resources ||= assets.map{|a| a.all_resources }.flatten
    end

  end # class Cast
end # module Easycast
