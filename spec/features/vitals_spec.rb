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

  context "when the request is made to '/health'" do
    it "responds to the request that it's healthy" do
      get "/health"
      expect(last_response.status).to eql(200)
      expect(last_response.body).to eql("OK")
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
