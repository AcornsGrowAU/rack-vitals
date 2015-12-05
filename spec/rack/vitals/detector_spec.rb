require "spec_helper"

describe ::Rack::Vitals::Detector do
  describe "#critical_checks_healthy?" do
    let(:check) { instance_double ::Rack::Vitals::Check }
    let(:check_collection) { [check] }
    let(:check_evaluator) { instance_double ::Rack::Vitals::CheckEvaluator }

    before do
      allow(::Rack::Vitals::CheckRegistrar).to receive(:critical_checks).and_return(check_collection)
      allow(::Rack::Vitals::CheckEvaluator).to receive(:new).and_return(check_evaluator)
      allow(check_evaluator).to receive(:run).and_return check_evaluator
      allow(check_evaluator).to receive(:down_state?)
    end

    it "gets the critical checks from the registrar" do
      expect(::Rack::Vitals::CheckRegistrar).to receive(:critical_checks).and_return(check_collection)
      subject.critical_checks_healthy?
    end

    it "iterates over each check" do
      expect(check_collection).to receive(:each)
      subject.critical_checks_healthy?
    end

    it "creates a new check evaluator with the yielded check" do
      expect(::Rack::Vitals::CheckEvaluator).to receive(:new).with(check)
      subject.critical_checks_healthy?
    end

    it "activates the check evaluator" do
      expect(check_evaluator).to receive(:run).and_return check_evaluator
      subject.critical_checks_healthy?
    end

    context "when the check state is 'down'" do
      it "returns false" do
        allow(check_evaluator).to receive(:down_state?).and_return true
        result = subject.critical_checks_healthy?
        expect(result).to be_falsey
      end
    end

    context "when there are no check states that are 'down'" do
      it "returns true" do
        allow(check_evaluator).to receive(:down_state?).and_return false
        result = subject.critical_checks_healthy?
        expect(result).to be_truthy
      end
    end
  end
end
