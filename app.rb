require 'sinatra'

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
		erb :index, locals: {faxes: faxes}
	end

	run! if __FILE__ == $0
end
