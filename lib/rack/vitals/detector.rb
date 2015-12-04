module Rack
  class Vitals::Detector
    def critical_checks_healthy?
      critical = ::Rack::Vitals::CheckRegistrar.critical_checks
      critical.each do |check|
        check_evaluator = ::Rack::Vitals::CheckEvaluator.new(check)
        check_evaluator.run
        return false if check_evaluator.down_state?
      end
      return true
    end
  end
end
