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
    end

    it "creates a rack request helper" do
      allow(subject).to receive(:requested_health_path?).and_return(true)
      expect(Rack::Request).to receive(:new).with(env).and_return(request)
      subject.call env
    end

    it "checks if the requested path is for the health check" do
      expect(subject).to receive(:requested_health_path?).with(request.path).and_return(true)
      subject.call env
    end

    context "when the get request is checking health" do
      it "shortcuts the middleware with a OK response" do
        allow(subject).to receive(:requested_health_path?).and_return(true)
        result = subject.call env
        expect(result).to eql [200, {}, ["OK"]]
      end
    end

    context "when the get request is not going to health" do
      before do
        allow(request).to receive(:path).and_return("/foo")
        allow(subject).to receive(:requested_health_path?).and_return(false)
      end

      it "passes the request through" do
        expect(app).to receive(:call).with env
        subject.call env
      end

      it "returns the needed rack array" do
        status = double
        headers = double
        response = double
        allow(app).to receive(:call).and_return([status, headers, response])
        result = subject.call env
        expect(result).to eql [status, headers, response]
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
end
