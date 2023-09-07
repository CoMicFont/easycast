module Easycast
  class Asset
    class Layers < Asset

      def initialize(cast, path, config)
        super(cast, path, config)
        @options = path[:options] || { }
        @assets  = path[:images].map { |i| Image.new(cast, i, config) }
        @sha = transformed_sha({
          paths: @assets.map{|a| a.path }
        })
        @external_path = "/assets/_layers/#{@sha}.png"
        @file = config.folder/("assets/_layers/#{@sha}.png")
      end

      def ensure!
        generate_layer!
      end

      def all_resources
        [ { path: "#{@external_path}", as: "image" } ]
      end

      def to_html(state, cast)
        %Q{<img src="#{@external_path}">}
      end

    private

      def generate_layer!
        return if @file.exists?

        puts "\nGenerating layer -> `#{@file}`"
        @file.parent.mkdir_p unless @file.parent.exists?

        sources = @assets.map{|a|
          a.ensure!
          a.target_image
        }

        cmd = %Q{convert #{sources.join(' ')} -background none -flatten #{@file}}
        puts "#{cmd}"
        `#{cmd}`
      end

    end # class Layers
  end # class Asset
end # module Easycast
