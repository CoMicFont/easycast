
module Easycast
  class Asset
    class Video < SimpleFile

      def to_html(state, cast)
        video_options = cast.videos || config.videos
        mode = state.scheduler.paused? ? :pause : :play
        loop = !!video_options[:loop][mode] ? "loop" : ""
        walk_on_end = video_options[:walk_on_end] && mode === :play
        tag = <<~HTML
          <video id="#{unique_id}" playsinline autoplay muted #{loop} source style="width: 1920px; height: auto;" src="#{ASSETS_PREFIX}/#{@path}" type="#{video_type}">This browser does not support the video tag.</video>
        HTML
        if walk_on_end
          tag += <<~HTML
            <script type='text/javascript'>
              document.getElementById('#{unique_id}').addEventListener('ended', function() {
                $.ajax({
                  url: "/tour/next",
                  method: 'POST',
                  data: {}
                });
              },false);
            </script>
          HTML
        end
        tag
      end

      def all_resources
        []
      end

    end

    class Mp4 < Video

      def video_type
        "video/mp4"
      end

    end # class Mp4

    class Webm < Video

      def video_type
        "video/webm"
      end

    end # class Webm

    class Ogg < Video

      def video_type
        "video/ogg"
      end

    end # class Ogg
  end # class Asset
end # module Easycast
