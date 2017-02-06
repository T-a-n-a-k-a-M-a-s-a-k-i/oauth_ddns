require "bundler"

Bundler.require

require "sinatra/config_file"

DB = Sequel.connect("sqlite://db/oauth_ddns.db")
