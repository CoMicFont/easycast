module Rack
  #
  # Sets HTTP response headers to ensure that browers and other web
  # middlewares won't ever cache the response.
  #
  # Stolen from https://github.com/cwninja/rack-nocache, currently
  # distributed without explicit licence.
  #
  class Nocache

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      [status, patch_response_headers(headers), body]
    end

  protected

    CACHE_BUSTER = {
      "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
      "Pragma" => "no-cache",
      "Expires" => "Fri, 29 Aug 1997 02:14:00 EST"
    }

    ALLOW_CACHE = {
      "Cache-Control" => "public, max-age=0, must-revalidate"
    }

    def patch_response_headers(hs)
      hs.merge(hs['ETag'] || hs['Last-Modified'] ? CACHE_BUSTER : CACHE_BUSTER)
    end

  end # class Nocache
end # module Rack