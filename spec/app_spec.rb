require "spec_helper"
require "rack/test"
require "./app" 
require "./services/flakiness_checker"
require_relative "../auth/authentication"

RSpec.describe "FaxApp", type: :request do
  include Rack::Test::Methods

  def app
    FaxApp.new
  end

  let(:auth_token) { "dnvp34023" }

  let(:fax_mock) { Fax.new(id: "1", file_path: "", receiver_number: 2, status: "pending", user_token: auth_token, created_at: Time.now)}

  describe "GET /faxes" do
    it "returns faxes associated with token" do
      allow_any_instance_of(Authentication::TokenValidator).to receive(:valid?).with(auth_token).and_return(true)
      allow_any_instance_of(Repositories::Faxes).to receive(:find_by_token).with(auth_token).and_return([fax_mock])

      header "Authorization", "Bearer #{auth_token}"
      get "/faxes"

      expect(last_response.status).to eq 200
      expect(last_response.body).to include("1")
    end
  end

  describe "GET /faxes/:id" do 
    it "returns fax by its id" do
      allow_any_instance_of(Authentication::TokenValidator).to receive(:valid?).with(auth_token).and_return(true)
      # id passed in as an integer, but params turn it into a string // take care of later
      allow_any_instance_of(Repositories::Faxes).to receive(:find).with(fax_mock.id).and_return(fax_mock)

      header "Authorization", "Bearer #{auth_token}"
      get "/faxes/#{fax_mock.id}"

      expect(last_response.status).to eq 200
      expect(last_response.body).to include("1")
    end
  end

  describe "POST /faxes" do

    let(:file) do
      Rack::Test::UploadedFile.new(
        StringIO.new("Amazing fax"), "text/plain", original_filename: "test.txt"
      )
    end

    before do
      allow(FlakinessChecker).to receive(:should_fail?).and_return(false)
      allow(File).to receive(:write).and_return(true)
    end

    it "creates and saves a fax with standard text file format" do
      allow_any_instance_of(Authentication::TokenValidator).to receive(:valid?).with(auth_token).and_return(true)

      header "Authorization", "Bearer #{auth_token}"
      post "/faxes", {
        receiver_number: "123",
        file: file
      }

      expect(last_response.status).to eq 201
      expect(last_response.body).to include("id").and include("receiver_number").and include("user_token")
    end

    it "doesn't create a fax if base64 encoded file is not of type text" do
      allow_any_instance_of(Authentication::TokenValidator).to receive(:valid?).with(auth_token).and_return(true)
      binary = "\x89PNG\r\n\x1A\n".b
      file = Rack::Test::UploadedFile.new(
        StringIO.new(binary), "image/png", original_filename: "test.png"
      )

      header "Authorization", "Bearer #{auth_token}"
      post "/faxes", {
        fax_number: "123",
        file: file
      }

      expect(last_response.status).to eq(400)
      expect(last_response.body).to include("Invalid file type")
    end

    it "doesn't allow to create a fax when token is incorrect" do

      header "Authorization", "Bearer invalid"
      post "/faxes", {
        receiver_number: "123",
        file: file
      }

      expect(last_response.status).to eq 403
      expect(last_response.body).to include("Forbidden: Invalid token")
    end
  end

  describe "POST /auth" do
    let(:tokens_path) { "./auth/tokens.json" }
    
    it "geerates a new auth token and returns it" do
      existing_tokens = ["abc123"]
      allow(SecureRandom).to receive(:hex).with(10).and_return("new_token")

      expect(File).to receive(:read).with(tokens_path).and_return(existing_tokens.to_json)
      expect(File).to receive(:write).with(tokens_path, existing_tokens + ["new_token"])

      post "/auth"

      expect(last_response.status).to eq 201
      expect(JSON.parse(last_response.body)).to eq("new_token")
    end
  end
end
