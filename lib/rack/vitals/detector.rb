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
  end
end
