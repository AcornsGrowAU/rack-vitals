require "spec_helper"

describe ::Rack::Vitals::CheckEvaluator do
  let(:procedure) { Proc.new { self } }
  let(:check) { instance_double ::Rack::Vitals::Check, procedure: procedure }
  subject { ::Rack::Vitals::CheckEvaluator.new(check) }

  describe "#initialize" do
    it "stores the passed in check" do
      result = subject.instance_variable_get(:@check)
      expect(result).to eql check
    end
  end

  describe "#run" do
    it "calls the check's block" do
      expect(subject.instance_variable_get(:@check)).to receive(:procedure)
      subject.run
    end

    it "evaluates the check procedure within its scope" do
      expect(subject).to receive(:instance_eval)
      subject.run
    end

    context "when the check procedure raises an exception" do
      it "sets the evaluation state to down" do
        allow(subject).to receive(:instance_eval).and_raise(StandardError)
        expect(subject).to receive(:down_state)
        subject.run
      end
    end

    context "when the check procedure does not raise an exception" do
      it "doesn't set the evaluation state to down" do
        expect(subject).not_to receive(:down_state)
        subject.run
      end
    end

    it "returns the instance of itself" do
      result = subject.run
      expect(result).to eql(subject)
    end
  end

  describe "#up_state" do
    it "sets the check evaluation state to up" do
      subject.up_state
      expect(subject.instance_variable_get(:@state)).to eql :up
    end
  end

  describe "#warn_state" do
    it "sets the check evaluation state to warn" do
      subject.warn_state
      expect(subject.instance_variable_get(:@state)).to eql :warn
    end
  end

  describe "#down_state" do
    it "sets the check evaluation state to down" do
      subject.down_state
      expect(subject.instance_variable_get(:@state)).to eql :down
    end
  end

  describe "#down_state?" do
    context "when the evaluator state is 'down'" do
      it "returns true" do
        subject.instance_variable_set(:@state, :down)
        expect(subject.down_state?).to be_truthy
      end
    end

    context "when the evaluator state is 'up'" do
      it "returns false" do
        subject.instance_variable_set(:@state, :up)
        expect(subject.down_state?).to be_falsey
      end
    end

    context "when the evaluator state is 'warn'" do
      it "returns false" do
        subject.instance_variable_set(:@state, :warn)
        expect(subject.down_state?).to be_falsey
      end
    end

    context "when the evaluator state is 'nil'" do
      it "returns false" do
        subject.instance_variable_set(:@state, nil)
        expect(subject.down_state?).to be_falsey
      end
    end
  end
end
