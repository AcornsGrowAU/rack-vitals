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

  describe "#generate_status_response" do
    let(:check) { instance_double ::Rack::Vitals::Check }
    let(:check_collection) { [check] }
    let(:check_result) { instance_double ::Rack::Vitals::CheckResult }
    let(:formatted_check) { { name: "foo", state: "up" } }
    let(:response_body) { [{ name: "foo", state: "up" }] }

    before do
      allow(registrar).to receive(:all_checks).and_return(check_collection)
      allow(::Rack::Vitals::CheckEvaluator).to receive(:run).and_return check_result
      allow(subject).to receive(:add_formatted_check_to_response_body).with(check_result).and_return(formatted_check)
    end

    it "gets all the required checks for status" do
      expect(registrar).to receive(:all_checks).and_return(check_collection)
      subject.generate_status_response
    end

    it "iterates over each check in the array" do
      expect(check_collection).to receive(:map)
      subject.generate_status_response
    end

    it "runs the check evaluator" do
      expect(::Rack::Vitals::CheckEvaluator).to receive(:run).with(check)
      subject.generate_status_response
    end

    it "formats the check results for the response body" do
      expect(subject).to receive(:add_formatted_check_to_response_body).with(check_result)
      subject.generate_status_response
    end

    it "converts the response body as json" do
      allow(check_collection).to receive(:map).and_return(response_body)
      expect(response_body).to receive(:to_json)
      subject.generate_status_response
    end
  end

  describe "#add_formatted_check_to_response_body" do
    let(:check_result) { instance_double ::Rack::Vitals::CheckResult, name: "foo", state: :up }

    it "adds the formatted hash to the response body" do
      result = subject.add_formatted_check_to_response_body(check_result)
      expect(result).to eql({ name: "foo", state: :up })
    end
  end
end
