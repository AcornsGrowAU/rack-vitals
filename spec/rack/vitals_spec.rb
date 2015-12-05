require 'spec_helper'

describe Rack::Vitals do
  let(:app) { double 'app' }
  subject { Rack::Vitals.new(app) }

  it 'has a version number' do
    expect(Rack::Vitals::VERSION).not_to be nil
  end

  describe "#initialize" do
    it "initializes the app" do
      expect(subject.instance_variable_get(:@app)).to eql app
    end
  end

  describe "#call" do
    let(:env) { double }
    let(:request) { double "Request", path: "/somepath" }

    before do
      allow(Rack::Request).to receive(:new).and_return request
      allow(subject).to receive(:health_vitals_response)
    end

    it "creates a rack request" do
      allow(subject).to receive(:requested_health_path?).and_return(true)
      expect(Rack::Request).to receive(:new).with(env).and_return(request)
      subject.call env
    end

    it "checks if the requested path is for the health check" do
      expect(subject).to receive(:requested_health_path?).with(request.path).and_return(true)
      subject.call env
    end

    context "when the requested path is for the health check" do
      before do
        allow(subject).to receive(:requested_health_path?).and_return(true)
      end

      it "gets the health vitals response" do
        expect(subject).to receive(:health_vitals_response)
        subject.call env
      end
      
      it "returns the health vitals response" do
        valid_response = double
        allow(subject).to receive(:health_vitals_response).and_return(valid_response)
        result = subject.call env
        expect(result).to eql valid_response
      end

      it "does not call the rest of the middleware stack" do
        expect(app).not_to receive(:call)
        subject.call env
      end
    end

    context "when the requested path is not for the health check" do
      before do
        allow(request).to receive(:path).and_return("/foo")
        allow(subject).to receive(:requested_health_path?).and_return(false)
      end

      it "passes the request to the the next middleware" do
        expect(app).to receive(:call).with env
        subject.call env
      end

      it "returns the result of the next middleware layer" do
        middleware_response = double
        allow(app).to receive(:call).and_return(middleware_response)
        result = subject.call env
        expect(result).to eql middleware_response
      end
    end
  end

  describe "#requested_health_path?" do
    context "when the path is for '/health'" do
      it "returns true" do
        result = subject.requested_health_path?("/health")
        expect(result).to be_truthy
      end
    end

    context "when the path is for '/health/'" do
      it "returns true" do
        result = subject.requested_health_path?("/health/")
        expect(result).to be_truthy
      end
    end

    context "when the path is for anything else" do
      it "returns false" do
        result = subject.requested_health_path?("/fooo/")
        expect(result).to be_falsey
      end
    end
  end

  describe ".register_checks" do
    it "passes the block to the check registrar" do
      expect(Rack::Vitals::CheckRegistrar).to receive(:register)
      Rack::Vitals.register_checks
    end
  end

  describe "#health_vitals_response" do
    let(:detector) { instance_double Rack::Vitals::Detector }

    before do
      allow(::Rack::Vitals::Detector).to receive(:new).and_return detector
      allow(detector).to receive(:critical_checks_healthy?)
    end

    it "creates a new vitals detector" do
      expect(Rack::Vitals::Detector).to receive(:new)
      subject.health_vitals_response
    end

    it "checks all the critical checks in the registrar" do
      expect(detector).to receive(:critical_checks_healthy?)
      subject.health_vitals_response
    end

    context "when the critical checks are healthy" do
      it "returns a healthy response" do
        allow(detector).to receive(:critical_checks_healthy?).and_return true
        result = subject.health_vitals_response
        expect(result).to match_array [200, {}, ["OK"]]
      end
    end

    context "when the critical checks are not healthy" do
      it "returns an unhealthy response" do
        allow(detector).to receive(:critical_checks_healthy?).and_return false
        result = subject.health_vitals_response
        expect(result).to match_array [503, {}, ["Service Unavailable"]]
      end
    end
  end
end
