module Easycast
  class Conversion < OpenStruct

    def initialize(data, config)
      super(data)
      @config = config
    end
    attr_reader :config

  end # class Conversion
end # module Easycast
