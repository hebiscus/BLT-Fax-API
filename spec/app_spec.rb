require "spec_helper"
require "rack/test"
require "./app" 
require "./services/flakiness_checker"
require './config'

RSpec.describe "FaxApp", type: :request do
  include Rack::Test::Methods

  def app
    FaxApp.new
  end

  describe "GET /faxes" do
    it "returns created faxes" do
      File.write("./faxes/fax-1-test.txt", "First fax")
      File.write("./faxes/fax-2-test.txt", "Second fax")

      header "Authorization", "Bearer #{AUTH_TOKEN}"
      get "/faxes"
      
      expect(last_response.status).to eq 200
    end

    xit "doesn't return created faxes when token is incorrect" do
      expect(response.status).to eq 403
    end
  end

  describe "POST /faxes" do
    it "creates and saves a fax with standard text file format" do
      allow(FlakinessChecker).to receive(:should_fail?).and_return(false)

      file = Rack::Test::UploadedFile.new(
        StringIO.new("Amazing fax"), "text/plain", original_filename: "test.txt"
      )

      header "Authorization", "Bearer #{AUTH_TOKEN}"
      post "/faxes", {
        fax_number: "123",
        file: file
      }

      expect(last_response).to be_ok
      expect(last_response.body).to include("File uploaded successfully!")

      saved = Dir.glob("./faxes/fax-123-*").first
      expect(File.read(saved)).to eq("Amazing fax")
    end

    it "doesn't create a fax if base64 encoded file is not of type text" do
      binary = "\x89PNG\r\n\x1A\n".b
      file = Rack::Test::UploadedFile.new(
        StringIO.new(binary), "image/png", original_filename: "test.png"
      )

      header "Authorization", "Bearer #{AUTH_TOKEN}"
      post "/faxes", {
        fax_number: "123",
        file: file
      }

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include("Invalid file type")
    end

    it "doesn't allow to create a fax when token is incorrect" do
      file = Rack::Test::UploadedFile.new(
        StringIO.new("Amazing fax"), "text/plain", original_filename: "test.txt"
      )

      post "/faxes", {
        fax_number: "123",
        file: file
      }

      p last_response
      expect(last_response.status).to eq 403
      expect(last_response.body).to include("Forbidden: Invalid token")
    end
  end
end
