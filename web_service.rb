class WebService < Sinatra::Base
  configure do
    set :sessions, true
    enable :method_override
  end

  helpers do
    def set_status(osn_identifier)
      @ipv4_status = Status.filter(
        osn_identifier.merge(:record_type => "ipv4_address")
      ).first

      @txt_status = Status.filter(
        osn_identifier.merge(:record_type => "txt")
      ).first
    end
  end

  use OmniAuth::Builder do
    provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  end
  
  put "/status" do

  end

  get "/status" do
    @request = request
    @ipv4_status
    @txt_status

    haml :status
  end

  delete "/status" do
    haml :status
  end

  get "/auth/:provider/callback" do
    omniauth_result = request.env["omniauth.auth"]
    set_status(
      :provide => omniauth_result["provider"],
      :user_id => omniauth_result["info"]["nickname"]
    )
  end

  put "/api/status" do

  end

  delete "/api/status" do

  end

  get "/" do
    haml :index
  end
end
