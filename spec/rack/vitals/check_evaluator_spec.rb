require "spec_helper"

describe ::Rack::Vitals::CheckEvaluator do
  let(:procedure) { Proc.new { "foo" } }
  let(:check) { instance_double ::Rack::Vitals::Check, procedure: procedure }
  let(:check_result) { instance_double ::Rack::Vitals::CheckResult }

  before do
    allow(::Rack::Vitals::CheckResult).to receive(:new).and_return(check_result)
  end

  describe ".run" do
    it "creates a check result object" do
      expect(::Rack::Vitals::CheckResult).to receive(:new)
      described_class.run(check)
    end

    it "evaluates the check procedure within its scope" do
      expect(check_result).to receive(:instance_eval)
      described_class.run(check)
    end

    context "when the check procedure raises an exception" do
      it "sets the check result state to down" do
        allow(check_result).to receive(:instance_eval).and_raise(StandardError)
        expect(check_result).to receive(:down)
        described_class.run(check)
      end
    end

    context "when the check procedure does not raise an exception" do
      it "doesn't set the evaluation state to down" do
        expect(subject).not_to receive(:down)
        described_class.run(check)
      end
    end

    it "returns the check result" do
      result = described_class.run(check)
      expect(result).to eql(check_result)
    end
  end
end
