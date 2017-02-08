require "bundler"
Bundler.require

Settings = YAML.load_file("./config.yml")
DB = Sequel.connect("sqlite://db/oauth_ddns.db")

Dir[File.expand_path("../models", __FILE__) << '/*.rb'].each do |file|
  require file
end

require_relative "dns_service"
require_relative "web_service"

Thread.new do
  DNSService.run!
end

run WebService
