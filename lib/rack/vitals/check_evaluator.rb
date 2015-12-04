module Rack
  class Vitals::CheckEvaluator
    def initialize(check)
      @check = check
    end

    def run
      procedure = @check.procedure
      begin
        self.instance_eval &procedure
      rescue => e
        self.down_state
      end
    end
    
    def up_state
      @state = :up
    end
    
    def warn_state
      @state = :warn
    end

    def down_state
      @state = :down
    end

    def down_state?
      @state == :down
    end
  end
end

