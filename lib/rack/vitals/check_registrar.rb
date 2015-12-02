module Rack
  class Vitals::CheckRegistrar
    def self.register &block
      @all_checks = Array.new
      @critical_checks = Array.new
      self.class_eval &block
    end

    def self.check(name, critical: false, &block)
      new_check = Rack::Vitals::Check.new name, &block
      @all_checks << new_check
      if critical == true
        @critical_checks << new_check
      end
    end
  end 
end
