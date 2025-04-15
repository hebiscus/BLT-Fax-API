require "spec_helper"
require "rack/test"
require_relative "../app" 

RSpec.describe "FaxApp", type: :request do
  include Rack::Test::Methods

  def app
    FaxApp.new
  end

  describe "GET /faxes" do
    it "returns created faxes" do
      File.write("./faxes/fax-1-test.txt", "First fax")
      File.write("./faxes/fax-2-test.txt", "Second fax")

      get "/faxes"
      
      expect(last_response.status).to eq 200
    end

    xit "doesn't return created faxes when token is incorrect" do
        expect(response.status).to eq 403
    end
  end

  # describe "POST /faxes" do
  #   it "creates a fax with standard text files" do

  #   end

  #   it "doesn't create a fax if base64 encoded file is not of type text" do

  #   end

  #   it "doesn't allow to create a fax when token is incorrect" do
  #       expect(response.status).to eq 402
  #   end
  # end
end
