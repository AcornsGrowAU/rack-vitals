module Rack
  class Vitals::CheckResult
    attr_reader :name, :state

    def initialize(name)
      @name = name
      @state = :down
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
