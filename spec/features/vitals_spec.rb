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
    ::Rack::Vitals.instance_variable_set(:@registrar, nil)
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

  context "when the request is made to '/status'" do
    before do
      Rack::Vitals.register_checks do
        check "foo", critical: true do
          up
        end

        check "bar" do
          down
        end

        check "baz" do
          warn
        end
      end
    end

    it "responds with a json object" do
      expected_body = [
        {
          name: "foo",
          state: "up"
        },
        {
          name: "bar",
          state: "down"
        },
        {
          name: "baz",
          state: "warn"
        }
      ].to_json
      get "/status"
      expect(last_response.status).to eql(200)
      expect(last_response.headers).to include({ "Content-Length" => "89", "Content-Type" => "application/json" })
      expect(last_response.body).to eql(expected_body)
    end

    context "when the status request has a trailing slash" do
      it "responds with a json object" do
        expected_body = [
          {
            name: "foo",
            state: "up"
          },
          {
            name: "bar",
            state: "down"
          },
          {
            name: "baz",
            state: "warn"
          }
        ].to_json
        get "/status/"
        expect(last_response.status).to eql(200)
        expect(last_response.headers).to include({ "Content-Length" => "89", "Content-Type" => "application/json" })
        expect(last_response.body).to eql(expected_body)
      end
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
