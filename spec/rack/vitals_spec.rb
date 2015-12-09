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
    let(:env) { double("env") }
    let(:dup_middleware) { double("duplicated middleware") }

    it "duplicates itself" do
      allow(dup_middleware).to receive(:_call).with(env)
      expect(subject).to receive(:dup).and_return(dup_middleware)
      subject.call(env)
    end

    it "executes the duplicated instance of call" do
      allow(subject).to receive(:dup).and_return(dup_middleware)
      expect(dup_middleware).to receive(:_call).with(env)
      subject.call(env)
    end
  end

  describe "#_call" do
    let(:env) { double }
    let(:request) { double "Request", path: "/somepath" }

    before do
      allow(Rack::Request).to receive(:new).and_return request
      allow(subject).to receive(:health_vitals_response)
    end

    it "creates a rack request" do
      allow(subject).to receive(:requested_health_path?).and_return(true)
      expect(Rack::Request).to receive(:new).with(env).and_return(request)
      subject._call env
    end

    it "checks if the requested path is for the health check" do
      expect(subject).to receive(:requested_health_path?).with(request.path).and_return(true)
      subject._call env
    end

    context "when the requested path is for the health check" do
      before do
        allow(subject).to receive(:requested_health_path?).and_return(true)
      end

      it "gets the health vitals response" do
        expect(subject).to receive(:health_vitals_response)
        subject._call env
      end
      
      it "returns the health vitals response" do
        valid_response = double
        allow(subject).to receive(:health_vitals_response).and_return(valid_response)
        result = subject._call env
        expect(result).to eql valid_response
      end

      it "does not call the rest of the middleware stack" do
        expect(app).not_to receive(:call)
        subject._call env
      end
    end

    context "when the requested path is not for the health check" do
      context "when the request path is for the status check" do
        before do
          allow(subject).to receive(:requested_status_path?).with(request.path).and_return(true)
        end

        it "checks if the requested path is for the status check" do
          expect(subject).to receive(:requested_status_path?).with(request.path).and_return(true)
          subject._call env
        end

        it "gets the status vitals response" do
          expect(subject).to receive(:status_vitals_response)
          subject._call env
        end

        it "returns the status vitals response" do
          valid_response = double
          allow(subject).to receive(:status_vitals_response).and_return(valid_response)
          result = subject._call env
          expect(result).to eql valid_response
        end

        it "does not call the rest of the middleware stack" do
          expect(app).not_to receive(:call)
          subject._call env
        end
      end

      context "when the request path is not for the status check" do
        before do
          allow(request).to receive(:path).and_return("/foo")
          allow(subject).to receive(:requested_health_path?).and_return(false)
        end

        it "passes the request to the the next middleware" do
          expect(app).to receive(:call).with env
          subject._call env
        end

        it "returns the result of the next middleware layer" do
          middleware_response = double
          allow(app).to receive(:call).and_return(middleware_response)
          result = subject._call env
          expect(result).to eql middleware_response
        end
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

  describe "#requested_status_path?" do
    context "when the path is for '/status'" do
      it "returns true" do
        result = subject.requested_status_path?("/status")
        expect(result).to be_truthy
      end
    end

    context "when the path is for '/status/'" do
      it "returns true" do
        result = subject.requested_status_path?("/status/")
        expect(result).to be_truthy
      end
    end

    context "when the path is for anything else" do
      it "returns false" do
        result = subject.requested_status_path?("/fooo/")
        expect(result).to be_falsey
      end
    end
  end

  describe ".register_checks" do
    let(:registrar) { instance_double(::Rack::Vitals::CheckRegistrar) }

    before do
      allow(Rack::Vitals).to receive(:registrar).and_return(registrar)
      allow(registrar).to receive(:register)
    end

    it "gets the registrar" do
      expect(Rack::Vitals).to receive(:registrar)
      Rack::Vitals.register_checks
    end

    it "registers the give block of checks" do
      expect(registrar).to receive(:register)
      Rack::Vitals.register_checks
    end
  end

  describe ".registrar" do
    context "when it's never been called before" do
      it "creates a new registrar" do
        vitals = Class.new ::Rack::Vitals
        expect(::Rack::Vitals::CheckRegistrar).to receive(:new)
        vitals.registrar
      end
    end

    context "when it's been called before" do
      it "returns the previously created registrar" do
        vitals = Class.new ::Rack::Vitals
        registrar = vitals.registrar
        result = vitals.registrar
        expect(result).to eql registrar
      end
    end
  end

  describe "#health_vitals_response" do
    let(:detector) { instance_double Rack::Vitals::Detector }
    let(:registrar) { instance_double ::Rack::Vitals::CheckRegistrar }

    before do
      allow(::Rack::Vitals::Detector).to receive(:new).and_return detector
      allow(detector).to receive(:critical_checks_healthy?)
      allow(::Rack::Vitals).to receive(:registrar).and_return(registrar)
    end

    it "creates a new vitals detector" do
      expect(Rack::Vitals::Detector).to receive(:new).with(registrar)
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

  describe "#status_vitals_response" do
    let(:detector) { instance_double Rack::Vitals::Detector }
    let(:response_body) { double }
    let(:registrar) { instance_double ::Rack::Vitals::CheckRegistrar }

    before do
      allow(::Rack::Vitals::Detector).to receive(:new).and_return detector
      allow(detector).to receive(:generate_status_response).and_return(response_body)
      allow(::Rack::Vitals).to receive(:registrar).and_return(registrar)
    end

    it "creates a new vitals detector" do
      expect(Rack::Vitals::Detector).to receive(:new).with(registrar)
      subject.status_vitals_response
    end

    it "generates the response body for the response" do
      expect(detector).to receive(:generate_status_response)
      subject.status_vitals_response
    end

    it "returns a status response" do
      result = subject.status_vitals_response
      expect(result).to match_array [200, {"Content-Type" => "application/json"}, [response_body]]
    end
  end
end
