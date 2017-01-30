class WebService < Sinatra::Base
  configure do
    set :sessions, true
  end

  use OmniAuth::Builder do
    provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  end
  
  put "/status" do

  end

  put "/api/status" do

  end

  get "/status" do
    haml :status
  end

  get "/auth/:provider/callback" do
    auth_result = request.env["omniauth.auth"]
  end

  get "/" do
    haml :index
  end
end
