module Easycast
  class Asset
    class Html < SimpleFile

      def to_html(state, cast)
        "<article>" + file_contents + "</article>"
      end

    end # class Html
  end # class Asset
end # module Easycast
