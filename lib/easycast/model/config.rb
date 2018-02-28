module Easycast
  #
  # This class is the ruby live version of the content found in
  # `scenes.yml`.
  #
  class Config < OpenStruct

    SCHEMA = Finitio::DEFAULT_SYSTEM.parse <<-FIO
      AssetPath = String( s | s.size>0 )
      Cast = {
        display: Integer
        remote: Boolean
        assets: [AssetPath]
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
        children :? [Node]
      }

      # Main, a set of scenes and a hierarchical structure
      # presenting them
      {
        scenes    :  [Scene]
        nodes     :  [Node]
        animation :? {
          frequency : String
          autoplay  : Boolean
        }
      }
    FIO

    def initialize(data)
      ensure_animation!(data)
      super(data)
      generate_node_indices!(data[:nodes], 0)
    end

    # Dresses some data as a config object
    def self.dress(data)
      new SCHEMA.dress(data)
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
      dress(yml.load)
    rescue Finitio::Error => ex
      raise ConfigError, "Corrupted scenes index file\n#{ex.root_cause.message}"
    end

    def scene_by_id(id)
      @scenes_by_id ||= scenes.each_with_object({}){|s,h| h[s[:id]] = Scene.new(s) }
      @scenes_by_id[id]
    end

  private

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
