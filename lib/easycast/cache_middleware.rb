module Easycast
  #
  # Sets HTTP response headers to ensure that browers and other web
  # middlewares won't ever cache the response in dev mode.
  #
  # Ensures static assets are properly cached in production mode.
  #
  # Adapted from https://github.com/cwninja/rack-nocache, currently
  # distributed without explicit licence.
  #
  class CacheMiddleware

    CACHE_BUSTER = {
      "Cache-Control" => "no-cache, no-store, max-age=0, must-revalidate",
      "Pragma" => "no-cache",
      "Expires" => "Fri, 29 Aug 1997 02:14:00 EST"
    }

    ALLOW_CACHE = {
      "Cache-Control" => "public, max-age=31536000"
    }

    def initialize(app)
      @app = app
    end

    def call(env)
      status, headers, body = @app.call(env)
      [status, patch_response_headers(status, headers), body]
    end

  protected

    def patch_response_headers(status, hs)
      if Easycast::DEVELOPMENT_MODE
        hs.merge(CACHE_BUSTER)
      else
        hs.merge(status == 304 || hs['ETag'] || hs['Last-Modified'] ? ALLOW_CACHE : CACHE_BUSTER)
      end
    end

  end # class CacheMiddleware
end # module Easycast
