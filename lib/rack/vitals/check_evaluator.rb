module Rack
  class Vitals::CheckEvaluator
    def self.run(check)
      check_result = ::Rack::Vitals::CheckResult.new(check.name)
      procedure = check.procedure
      begin
        check_result.instance_eval &procedure
      rescue => e
        check_result.down
      end
      return check_result
    end

    def name
      @check.name.gsub(" ", "_").to_sym
    end
  end
end

