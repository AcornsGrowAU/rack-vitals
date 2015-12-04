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
      all_checks = ::Rack::Vitals::CheckRegistrar.all_checks
      all_checks.each do |check|
        check_evaluator = ::Rack::Vitals::CheckEvaluator.new(check)
        check_evaluator.run
        add_formatted_check_to_response_body(check_evaluator)
      end
      return response_body.to_json
    end

    def response_body
      @response_body ||= {}
    end

    def add_formatted_check_to_response_body(check_evaluator)
      formatted_check_status = { check_evaluator.name => { state: check_evaluator.state }}
      response_body.merge! formatted_check_status
    end
  end
end
