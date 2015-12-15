require "rack"
require "rack/vitals/version"
require "rack/vitals/check"
require "rack/vitals/check_evaluator"
require "rack/vitals/check_registrar"
require "rack/vitals/check_result"
require "rack/vitals/detector"

module Rack
  class Vitals
    HEALTH_PATH_NAMES = ["/health", "/health/"]
    STATUS_PATH_NAMES = ["/status", "/status/"]

    def initialize(app)
      @app = app
    end

    def call(env)
      dup._call(env)
    end

    def _call(env)
      request = Rack::Request.new(env)
      if self.requested_health_path?(request.path)
        return self.health_vitals_response
      elsif self.requested_status_path?(request.path)
        return self.status_vitals_response
      else
        return @app.call(env)
      end
    end

    def requested_health_path?(request_path)
      return HEALTH_PATH_NAMES.include?(request_path)
    end

    def requested_status_path?(request_path)
      return STATUS_PATH_NAMES.include?(request_path)
    end

    def self.register_checks &block
      self.registrar.register &block
    end

    def self.registrar
      @registrar ||= ::Rack::Vitals::CheckRegistrar.new
    end

    def health_vitals_response
      detector = ::Rack::Vitals::Detector.new(::Rack::Vitals.registrar)
      if detector.critical_checks_healthy?
        return [200, {}, ["OK"]]
      else
        return [503, {}, ["Service Unavailable"]]
      end
    end

    def status_vitals_response
      detector = ::Rack::Vitals::Detector.new(::Rack::Vitals.registrar)
      response_body = detector.generate_status_response
      return [200, { "Content-Type" => "application/json" }, [response_body]]
    end
  end
end
