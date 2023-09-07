module Easycast
  class Asset
    class Layers < Compound

      def initialize(path, config)
        super(path, config)
        @options = path[:options] || { }
        @assets  = path[:images].map { |i| Image.new(i, config) }
        @sha = Digest::SHA1.hexdigest(@assets.map{|a| a.path }.join('/'))
        @external_path = "_layers/#{@sha}.png"
        @file = config.folder/("assets/#{@external_path}")
      end

      def ensure!
        super
        generate_layer!
      end

      def all_resources
        [ { path: "/#{@external_path}", as: "image" } ]
      end

      def to_html(state, cast)
        %Q{<img src="#{ASSETS_PREFIX}/#{@external_path}">}
      end

    private

      def generate_layer!
        return if @file.exists?

        @file.parent.mkdir_p unless @file.parent.exists?
        puts "Generating asset `#{@file}`"
        Path("/tmp/easycast").mkdir_p
        sources = @assets.map{|a|
          source = "/tmp/easycast/#{a.file.basename}"
          cmd = convert(a.file, source)
          puts "#{cmd}"
          `#{cmd}`
          source
        }
        [
          %Q{convert #{sources.join(' ')} -background none -flatten #{@file}},
          convert(@file, @file)
        ].each do |cmd|
          puts "#{cmd}"
          `#{cmd}`
        end
      end

    end # class Layers
  end # class Asset
end # module Easycast
