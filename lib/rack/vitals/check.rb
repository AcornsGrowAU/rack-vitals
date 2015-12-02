module Rack
  class Vitals::Check
    def initialize(name, &block)
      @name = name
      @check = block
    end
  end
end
