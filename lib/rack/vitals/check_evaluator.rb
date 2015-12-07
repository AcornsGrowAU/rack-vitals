module Rack
  class Vitals::CheckEvaluator
    def initialize(check)
      @state = :down
      @check = check
    end

    def run
      procedure = @check.procedure
      begin
        self.instance_eval &procedure
      rescue => e
        self.down
      end
    end
    
    def up
      @state = :up
    end
    
    def warn
      @state = :warn
    end

    def down
      @state = :down
    end

    def down?
      @state == :down
    end
  end
end

