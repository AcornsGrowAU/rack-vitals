module Rack
  class Vitals
    class Detector
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
        response_body = @registrar.all_checks.map do |check|
          check_result = ::Rack::Vitals::CheckEvaluator.run(check)
          format_check_to_response_body(check_result)
        end
        return response_body.to_json
      end

      def format_check_to_response_body(check_result)
        return { name: check_result.name, state: check_result.state }
      end
    end
  end
end
