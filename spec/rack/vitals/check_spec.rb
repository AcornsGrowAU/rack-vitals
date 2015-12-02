require "spec_helper"

describe Rack::Vitals::Check do
  describe "#initalize" do
    it "saves the given name" do
      result = described_class.new("some name")
      expect(result.instance_variable_get(:@name)).to eql "some name"
    end
    
    it "saves the given block" do
      block = Proc.new {}
      result = described_class.new("some name", &block)
      expect(result.instance_variable_get(:@check)).to eql block
    end
  end
end
