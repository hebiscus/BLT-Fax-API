require 'sinatra'
require "ostruct"
require_relative "services/flakiness_checker"
require './config'
require "./models/fax"
require "./repositories/faxes"

class FaxApp < Sinatra::Base

  # @param [String] fax_number
  # @param [File] file
	post "/faxes" do
    halt 403, "Forbidden: Invalid token" unless authenticated?
    return [500, { 'Content-Type' => 'text/plain' }, ["Error: Something went wrong...maybe check if it's raining? Server might be under water"]] if FlakinessChecker.should_fail?
		return [400, { 'Content-Type' => 'text/plain' }, ["No file selected"]] unless params[:file] && (tempfile = params[:file][:tempfile])
    return [400, { 'Content-Type' => 'text/plain' }, ["Invalid file type"]]  unless params[:file][:type] == "text/plain"
    
    fax_uuid = SecureRandom.uuid
  	target = "./faxes/fax-#{fax_uuid}"
		File.open(target, 'wb') {|f| f.write(tempfile.read)}

    new_fax = Fax.new(id: fax_uuid, file_path: target, receiver_number: params[:receiver_number], status: "pending", user_token: token)

    begin
      faxes = JSON.parse(File.read("./db/faxes.json"))
    rescue
      faxes = {}
    end

    faxes[new_fax.id] = new_fax.to_h
    File.write("./db/faxes.json", JSON.pretty_generate(faxes))
    
    [201, { 'Content-Type' => 'json' }, [new_fax.to_h.to_json]]
	end

  get "/faxes/:id" do
    fax = Repositories::Faxes.new.find_with_content(params[:id])
    if fax
      [200, { 'Content-Type' => 'json' }, [fax.to_h_with_content.to_json]]
    else 
      [404, { 'Content-Type' => 'json' }, ["Fax with that id doesn't exist"]]
    end
  end

	get "/faxes" do
    halt 403, "Forbidden: Invalid token" unless authenticated?
    faxes_directory = Dir.new("./faxes")
    
    faxes = faxes_directory.each_child.map do |fax|
      begin
        fax_path = File.join(faxes_directory.path, fax)
        fax_content = File.read(fax_path)
        
        fax_name = File.basename(fax)
        fax_number = fax_name.split("-")[1]
        fax_created_at = File.birthtime(fax_path).strftime("%d/%m/%Y-%H:%M:%S")
        
        OpenStruct.new(content: fax_content, fax_name: fax_name, fax_number: fax_number, created_at: fax_created_at)
      rescue => e
        puts "skipping #{fax} because of #{e}"
        next
      end
    end.sort_by { |fax| fax.created_at}.reverse

		erb :index, locals: {faxes: faxes}
	end

  post "/auth" do
    token = SecureRandom.hex(10)

    begin
      tokens = JSON.parse(File.read("tokens.json"))
    rescue
      tokens = []
    end

    tokens << token
    File.write("tokens.json", tokens)
  
    [201, { 'Content-Type' => 'json' }, token.to_json]
  end

  private

  def authenticated?
    tokens = JSON.parse(File.read("tokens.json"))
    tokens.include?(token)
  end

  def token
    request.env["HTTP_AUTHORIZATION"].split(" ")[1]
  end

	run! if __FILE__ == $0
end
