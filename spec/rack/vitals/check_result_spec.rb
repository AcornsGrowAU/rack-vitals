require "spec_helper"

describe ::Rack::Vitals::CheckResult do
  let(:check) { instance_double ::Rack::Vitals::Check, name: "bar" }
  subject { ::Rack::Vitals::CheckResult.new(check.name) }

  describe "#initialize" do
    it "sets the default state to down" do
      result = subject.instance_variable_get(:@state)
      expect(result).to eql :down
    end

    it "sets the name of the check that the results are for" do
      result = subject.instance_variable_get(:@name)
      expect(result).to eql "bar"
    end
  end

  describe "#up" do
    it "sets the check evaluation state to up" do
      subject.up
      expect(subject.instance_variable_get(:@state)).to eql :up
    end
  end

  describe "#warn" do
    it "sets the check evaluation state to warn" do
      subject.warn
      expect(subject.instance_variable_get(:@state)).to eql :warn
    end
  end

  describe "#down" do
    it "sets the check evaluation state to down" do
      subject.down
      expect(subject.instance_variable_get(:@state)).to eql :down
    end
  end

  describe "#down?" do
    context "when the evaluator state is 'down'" do
      it "returns true" do
        subject.instance_variable_set(:@state, :down)
        expect(subject.down?).to be_truthy
      end
    end

    context "when the evaluator state is 'up'" do
      it "returns false" do
        subject.instance_variable_set(:@state, :up)
        expect(subject.down?).to be_falsey
      end
    end

    context "when the evaluator state is 'warn'" do
      it "returns false" do
        subject.instance_variable_set(:@state, :warn)
        expect(subject.down?).to be_falsey
      end
    end
  end
end
