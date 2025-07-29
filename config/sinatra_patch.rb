require "sinatra/base"

module Sinatra
  class Base
    configure do
      set :bind, '0.0.0.0' 
      set :host_authorization, { permitted_hosts: ["127.0.0.1", "localhost", "blt-shop.onrender.com"] }
    end
  end
end
