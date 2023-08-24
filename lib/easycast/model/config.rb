module Easycast
  #
  # This class is the ruby live version of the content found in
  # `scenes.yml`.
  #
  class Config < OpenStruct

    SCHEMA = Finitio::DEFAULT_SYSTEM.parse <<-FIO
      Several = Integer(i | i >= 0 )
      AssetPath = String( s | s.size>0 )
      AssetOptions = {
        interval :? Integer
        ...
      }

      AnimationOption = {
        frequency : String
        autoplay  : Boolean
      }

      VideoOptions = {
        loop: {
          pause : Boolean
          play  : Boolean
        }
        walk_on_end : Boolean
      }

      Gallery = {
        type    : String( s | s == "gallery" )
        options :? AssetOptions
        images  :  [AssetPath]
      }

      Layers = {
        type    : String( s | s == "layers" )
        options :? AssetOptions
        images  :  [AssetPath]
      }

      Cast = {
        display : Integer
        remote  : Boolean
        videos  :? VideoOptions
        assets  : [AssetPath|Gallery|Layers]
      }

      Scene.Id = String
      Scene = {
        id: Scene.Id
        name: String
        cast: [Cast]
      }

      Node = {
        name: String
        children :? [Node]
      } | {
        scene: Scene.Id
        repeat :? Several
        children :? [Node]
      }

      Station = {
        name     :  String
        roles    :  [String]
        displays :? [Display]
      }

      DisplaySize = String( s | s =~ /\\d+x\\d+/ )
      DisplayPosition = String( s | s =~ /\\d+.\\d+/ )

      Display = {
        identifier: Integer
        size: DisplaySize
        position: DisplayPosition
      }

      # Main, a set of scenes and a hierarchical structure
      # presenting them
      {
        scenes    :  [Scene]
        nodes     :  [Node]
        stations  :? [Station]
        animation :? AnimationOption
        videos    :? VideoOptions
      }
    FIO

    def initialize(data, scenes_file)
      @scenes_file = scenes_file
      @folder = scenes_file && scenes_file.parent
      @saved_mtime = scenes_file && scenes_file.mtime
      ensure_animation!(data)
      super(data)
      generate_node_indices!(data[:nodes], 0)
    end
    attr_reader :scenes_file, :saved_mtime, :folder

    # Dresses some data as a config object
    def self.dress(data, world = {})
      new SCHEMA.dress(data), world[:scenes_file]
    end

    #
    # Loads a Scenes instance from a given folder.
    #
    # @raises ScenesError if something goes wrong with the folder or its
    #         structure.
    #
    def self.load(folder)
      raise ConfigError, "Scenes folder does not exist `#{folder}`" unless folder.directory?
      yml = folder/"scenes.yml"
      raise ConfigError, "Missing scenes index file `#{yml}`" unless yml.file?
      dress(yml.load, scenes_file: yml)
    rescue Finitio::Error => ex
      raise ConfigError, "Corrupted scenes index file\n#{ex.root_cause.message} (#{ex.root_cause&.location})"
    end

    def outdated?
      scenes_file && scenes_file.mtime > saved_mtime
    end

    def scene_by_id(id)
      @scenes_by_id ||= _scenes.each_with_object({}){|s,h| h[s[:id]] = s }
      @scenes_by_id[id]
    end

    def each_station(&block)
      _stations.each(&block)
    end

    def station_by_name(name)
      @stations_by_name ||= _stations.each_with_object({}){|s,h| h[s[:name]] = s }
      @stations_by_name[name]
    end

    def ensure_assets!
      error = nil
      _scenes.each do |s|
        begin
          s.ensure_assets!
        rescue => ex
          error ||= ex
          puts "Wrong scene #{s[:id]}: #{ex.message}"
        end
      end
      raise error if error
      self
    end

    def check!
      check_nodes!(nodes)
      self
    end

    def check_nodes!(nodes)
      nodes.each do |node|
        if node[:scene]
          scene = scene_by_id(node[:scene])
          raise "Unknown scene `#{node[:scene]}`" unless scene
        elsif node[:children]
          check_nodes!(node[:children])
        end
      end
    end

    def videos
      self[:videos] || {
        loop: { play: false, pause: true }
      }
    end

  private

    def _scenes
      @_scenes ||= scenes.map{|s| Scene.new(s, self) }
    end

    def _stations
      @_stations ||= (stations || default_stations).map{|s| Station.new(s, self) }
    end

    def default_stations
      [
        {
          name: "master",
          roles: ["master", "displays"],
          displays: [
            {
              identifier: 0,
              size: "1920x1080",
              position: "0,0",
            },
          ],
        },
        {
          name: "slave",
          roles: ["slave", "displays"],
          displays: [
            {
              identifier: 1,
              size: "1920x1080",
              position: "0,0",
            },
          ],
        },
      ]
    end

    def ensure_animation!(data)
      data[:animation] ||= {}
      data[:animation][:frequency] ||= '45s'
      data[:animation][:autoplay] = true unless data[:animation].has_key?(:autoplay)
    end

    def generate_node_indices!(remaining_nodes, i)
      return if remaining_nodes.empty?
      node, *tail = *remaining_nodes
      node.merge!(index: i)
      children = node[:children] ? node[:children] : []
      generate_node_indices!(children + tail, i+1)
    end

  end # class Config
end # module Easycast
