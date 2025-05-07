require "bundler/setup"

require "sinatra"
require "sinatra/base"

require "faraday"

# lib contains code that is *not* directly related to serving web requests.
# Web services will depend on modules in lib to provide data.
Dir["lib/**/*.rb"].each { require_relative it }

module RetroBridge
  class Web < Sinatra::Base
    ROOT = File.dirname(__FILE__)

    enable :logging

    use Rack::ETag
    use Rack::Runtime

    # This app is designed to impersonate other hosts.
    set :host_authorization, {permitted_hosts: []}

    set :root, ROOT
    set :public_folder, File.join(ROOT, "static")
  end
end

# Routes are handlers for web requests.
Dir["web/routes/**/*.rb"].each { require_relative it }
