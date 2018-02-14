module Easycast
  module Views
    #
    # Main class for all views.
    #
    class View < Mustache

      def initialize(config)
        @config = config
      end
      attr_reader :config

    end
  end
end
