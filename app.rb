require "bundler/setup"

require "sinatra"
require "sinatra/base"

require "faraday"

module RetroBridge
  class Web < Sinatra::Base
    ROOT = File.dirname(__FILE__)

    set :root, ROOT
    set :public_folder, File.join(ROOT, "static")

    Dir["./lib/*.rb"].each { require_relative it }
    Dir["./web/routes/*.rb"].each { require_relative it }
  end
end
