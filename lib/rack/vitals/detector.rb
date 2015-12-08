module Rack
  class Vitals::Detector
    def initialize(registrar)
      @registrar = registrar
    end

    def critical_checks_healthy?
      @registrar.critical_checks.each do |check|
        check_result = ::Rack::Vitals::CheckEvaluator.run(check)
        return false if check_result.down?
      end
      return true
    end

    def generate_status_response
      reset_response_body if response_body.length > 0
      @registrar.all_checks.each do |check|
        check_result = ::Rack::Vitals::CheckEvaluator.run(check)
        add_formatted_check_to_response_body(check_result)
      end
      return response_body.to_json
    end

    def add_formatted_check_to_response_body(check_result)
      response_body << { name: check_result.name, state: check_result.state }
    end

    def response_body
      @response_body ||= []
    end

    def reset_response_body
      @response_body = []
    end
  end
end
