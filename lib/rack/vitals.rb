require "rack/vitals/check"
require "rack/vitals/check_registrar"
require "rack/vitals/version"
require "rack"

module Rack
  class Vitals
    PATH_NAMES = ["/health", "/health/"]

    def initialize(app)
      @app = app
    end

    def call(env)
      request = Rack::Request.new(env)
      if self.requested_health_path?(request.path)
        return [200, {}, ["OK"]]
      else
        return @app.call(env)
      end
    end

    def requested_health_path?(request_path)
      return PATH_NAMES.include?(request_path)
    end

    def self.register_checks &block
      Rack::Vitals::CheckRegistrar.register &block
    end
  end
end
