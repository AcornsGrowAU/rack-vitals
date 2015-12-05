module Rack
  class Vitals::CheckRegistrar
    def self.register &block
      self.class_eval &block
    end

    def self.check(name, critical: false, &block)
      new_check = Rack::Vitals::Check.new name, &block
      self.all_checks << new_check
      if critical == true
        self.critical_checks << new_check
      end
    end

    def self.critical_checks
      return @critical_checks ||= Array.new
    end

    def self.all_checks
      return @all_checks ||= Array.new
    end
  end 
end
