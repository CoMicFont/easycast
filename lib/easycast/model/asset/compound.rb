module Easycast
  class Asset
    class Compound< Asset

      def ensure!
        @assets.each do |a|
          a.ensure!
        end
      end

    end # class Compound
  end # class Asset
end # module Easycast
