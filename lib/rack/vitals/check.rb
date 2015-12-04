module Rack
  class Vitals::Check
    attr_reader :name, :procedure

    def initialize(name, &block)
      @name = name
      @procedure = block
    end
  end
end
