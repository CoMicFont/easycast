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
      Scene = {
        id: String
        name: String
        cast: [Cast]
      }
      Node = {
        name: String
        children :? [Node]
      } | {
        scene: String
        children :? [Node]
      }
      {
        scenes: [Scene]
        nodes: [Node]
      }
    FIO

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
      yml_data = yml.load
      new SCHEMA.dress(yml_data)
    rescue Finitio::Error => ex
      raise ConfigError, "Corrupted scenes index file\n#{ex.root_cause.message}"
    end

    #
    # Returns the index-th node as a Node object
    # the nodes are indexed by a depth-search in the tree of nodes
    # example:
    #   t =     a          t[0] = a     t[5] = f
    #          / \         t[1] = b
    #         b   c        t[2] = d
    #        /   / \       t[3] = c
    #       d   e   f      t[4] = e
    #
    def node(index)
      rec_node(index, nodes, index)
    end

    private def rec_node(search_index, remaining_nodes, index)
      if remaining_nodes.empty? then raise ArgumentError, "Index out of nodes bounds: " + index.to_s
      else
        n, *tail = *remaining_nodes
        if search_index == 0 then Node.new(n.merge(index: index))
        else
          children = n[:children] ? n[:children] : []
          rec_node(search_index - 1, children + tail, index)
        end
      end
    end

    #
    # Allows iterating over Node instances.
    #
    def each
      return to_enum unless block_given?
      nodes.each_with_index do |n, i|
        yield(node(i))
      end
    end

    def scene_by_id(id)
      @scenes_by_id ||= scenes.each_with_object({}){|s,h| h[s[:id]] = Scene.new(s) }
      @scenes_by_id[id]
    end

  end # class Config
end # module Easycast
