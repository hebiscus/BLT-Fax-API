require 'sinatra'
require "ostruct"

class FaxApp < Sinatra::Base

  # @param [String] fax_number
  # @param [File] file
	post "/fax" do
		p params
		return "No file selected" unless params[:file] && (tempfile = params[:file][:tempfile]) && (name = params[:file][:filename])

  	target = "./faxes/fax-#{params[:fax_number]}-#{name}"
		File.open(target, 'wb') {|f| f.write(tempfile.read)}
    "File uploaded successfully!"
	end

	get "/faxes" do
    faxes_directory = Dir.new("./faxes")
    
    faxes = faxes_directory.each_child.map do |fax| 
      fax_content = File.read(File.join(faxes_directory.path, fax))
      fax_name = File.basename(fax)
      OpenStruct.new(content: fax_content, fax_name:)
    end

    # p faxes[0]
		erb :index, locals: {faxes: faxes}
	end

	run! if __FILE__ == $0
end
