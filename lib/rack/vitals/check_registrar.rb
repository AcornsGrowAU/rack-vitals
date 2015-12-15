module Rack
  class Vitals
    class CheckRegistrar
      def register &block
        self.instance_eval &block
      end

      def check(name, critical: false, &block)
        new_check = Rack::Vitals::Check.new name, &block
        self.all_checks << new_check
        if critical == true
          self.critical_checks << new_check
        end
      end

      def critical_checks
        return @critical_checks ||= Array.new
      end

      def all_checks
        return @all_checks ||= Array.new
      end
    end
  end 
end
