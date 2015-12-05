require "spec_helper"

describe Rack::Vitals::Check do
  subject do
    ::Rack::Vitals::Check.new "check name" do
      "some check" == "some check"
    end
  end

  describe "#initalize" do
    it "saves the given name" do
      check = described_class.new("some name")
      expect(check.instance_variable_get(:@name)).to eql "some name"
    end
    
    it "saves the given block" do
      block = Proc.new {}
      check = described_class.new("some name", &block)
      expect(check.instance_variable_get(:@procedure)).to eql block
    end
  end

  describe "#procedure" do
    it "returns the procedure that belongs to the check" do
      block = Proc.new {}
      check = described_class.new("some name", &block)
      result = check.procedure
      expect(result).to eql block
    end
  end
end
