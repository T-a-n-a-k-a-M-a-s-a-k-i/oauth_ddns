require "bundler"

Bundler.require

DB = Sequel.connect("sqlite://db/oauth_ddns.db")
