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
    let(:response_body) { { foo: { state: :up }, bar: { state: :down } } }

    before do
      allow(registrar).to receive(:all_checks).and_return(check_collection)
      allow(::Rack::Vitals::CheckEvaluator).to receive(:run).and_return check_result
      allow(subject).to receive(:add_formatted_check_to_response_body).with(check_result)
      allow(subject).to receive(:response_body).and_return(response_body)
    end

    context "when the detector has already generated a response body" do
      it "resets the response body to be empty" do
        allow(subject).to receive(:response_body).and_return ["some previous check"]
        expect(subject).to receive(:reset_response_body)
        subject.generate_status_response
      end
    end

    context "when the detector has not already generated a response body" do
      it "doesn't reset the response body" do
        allow(subject).to receive(:response_body).and_return []
        expect(subject).not_to receive(:reset_response_body)
        subject.generate_status_response
      end
    end

    it "gets all the required checks for status" do
      expect(registrar).to receive(:all_checks).and_return(check_collection)
      subject.generate_status_response
    end

    it "iterates over each check" do
      expect(check_collection).to receive(:each)
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
      expect(response_body).to receive(:to_json)
      subject.generate_status_response
    end
  end

  describe "#add_formatted_check_to_response_body" do
    let(:check_result) { instance_double ::Rack::Vitals::CheckResult, name: "foo", state: :up }

    it "adds the formatted hash to the response body" do
      expect(subject.response_body).to receive(:<<).with({ name: "foo", state: :up })
      subject.add_formatted_check_to_response_body(check_result)
    end
  end

  describe "#response_body" do
    context "when it's called for the first time" do
      it "creates an empty hash" do
        result = subject.response_body
        expect(result).to eql([])
      end
    end

    context "when it's called multiple times" do
      it "returns the memoized array" do
        subject.response_body << { foo: "stuff"}
        result = subject.response_body
        expect(result).to eql([{ foo: "stuff" }])
      end
    end
  end

  describe "#reset_response_body" do
    it "resets the response body to an empty hash" do
      subject.instance_variable_set(:@response_body, ["something here"])
      subject.reset_response_body
      result = subject.instance_variable_get(:@response_body)
      expect(result).to eql []
    end
  end
end
