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
      fax_number = fax_name.split("-")[1]
      fax_created_at = File.birthtime(File.join(faxes_directory.path, fax)).strftime("%d/%m/%Y-%H:%M:%S")
      OpenStruct.new(content: fax_content, fax_name:, fax_number:, created_at: fax_created_at)
    end

    p faxes[0].content
		erb :index, locals: {faxes: faxes}
	end

	run! if __FILE__ == $0
end
