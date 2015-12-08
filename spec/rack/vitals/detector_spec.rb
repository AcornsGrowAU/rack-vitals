require "spec_helper"

describe ::Rack::Vitals::Detector do
  let(:registrar) { instance_double ::Rack::Vitals::CheckRegistrar }
  subject {described_class.new(registrar)}

  describe "#initialize" do
    it "stores the registrar to detect the vitals for" do
      detector = ::Rack::Vitals::Detector.new(registrar)
      expect(detector.instance_variable_get(:@registrar)).to eql(registrar)
    end
  end

  describe "#critical_checks_healthy?" do
    let(:check) { instance_double ::Rack::Vitals::Check }
    let(:check_collection) { [check] }
    let(:check_result) { instance_double ::Rack::Vitals::CheckResult }

    before do
      allow(registrar).to receive(:critical_checks).and_return(check_collection)
      allow(::Rack::Vitals::CheckEvaluator).to receive(:run).with(check).and_return(check_result)
      allow(check_result).to receive(:down?)
    end

    it "gets the critical checks from the registrar" do
      expect(registrar).to receive(:critical_checks).and_return(check_collection)
      subject.critical_checks_healthy?
    end

    it "iterates over each check" do
      expect(check_collection).to receive(:each)
      subject.critical_checks_healthy?
    end

    it "runs the check through the evaluator" do
      expect(::Rack::Vitals::CheckEvaluator).to receive(:run).with(check)
      subject.critical_checks_healthy?
    end

    context "when the check state is 'down'" do
      it "returns false" do
        allow(check_result).to receive(:down?).and_return true
        result = subject.critical_checks_healthy?
        expect(result).to be_falsey
      end
    end

    context "when there are no check states that are 'down'" do
      it "returns true" do
        allow(check_result).to receive(:down?).and_return false
        result = subject.critical_checks_healthy?
        expect(result).to be_truthy
      end
    end
  end
end
