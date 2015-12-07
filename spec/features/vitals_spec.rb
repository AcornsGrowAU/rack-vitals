require 'spec_helper'
require 'rack/test'

describe "rack Health middleware" do
  include Rack::Test::Methods

  def app
    Rack::Builder.app do
      use Rack::Vitals
      run lambda { |env| [123, {}, ["foo"]] }
    end
  end

  after do
    ::Rack::Vitals::CheckRegistrar.instance_variable_set(:@critical_checks, nil)
    ::Rack::Vitals::CheckRegistrar.instance_variable_set(:@all_check, nil)
  end

  context "when the request is made to '/health'" do
    it "responds to the request that it's healthy" do
      get "/health"
      expect(last_response.status).to eql(200)
      expect(last_response.body).to eql("OK")
    end

    context "when the app has a working critical dependency" do
      before do
        Rack::Vitals.register_checks do
          check "some dependency", critical: true do
            up
          end
        end
      end

      it "responds to the request that it's healthy" do
        get "/health"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql("OK")
      end
    end

    context "when the app has a critical dependency in a warn state" do
      before do
        Rack::Vitals.register_checks do
          check "some dependency", critical: true do
            warn
          end
        end
      end

      it "responds to the request that it's healthy" do
        get "/health"
        expect(last_response.status).to eql(200)
        expect(last_response.body).to eql("OK")
      end
    end

    context "when the app has a broken critical dependency" do
      before do
        Rack::Vitals.register_checks do
          check "some dependency", critical: true do
            down
          end
        end
      end

      it "responds to the request that is not healthy" do
        get "/health"
        expect(last_response.status).to eql(503)
        expect(last_response.body).to eql("Service Unavailable")
      end
    end

    context "when the check doesn't define a state for the check to be in" do
      before do
        Rack::Vitals.register_checks do
          check "some dependency", critical: true do
            # No states defined
          end
        end
      end

      it "responds the the request that is not healthy" do
        get "/health"
        expect(last_response.status).to eql(503)
        expect(last_response.body).to eql("Service Unavailable")
      end
    end
  end

  context "when the request is made to '/health/'" do
    it "responds to the request that it's healthy" do
      get "/health/"
      expect(last_response.status).to eql(200)
      expect(last_response.body).to eql("OK")
    end
  end

  context "when the request is made to any other path" do
    it "passes the request through the middleware to the rest of the app" do
      get "/foo"
      expect(last_response.status).to eql(123)
      expect(last_response.body).to eql("foo")
    end
  end
end
