require "bundler"
Bundler.require
require "sinatra/config_file"

Thread.new do
  DNSService.run!
end

DB = Sequel.connect("sqlite://db/oauth_ddns.db")
