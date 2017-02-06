class WebService < Sinatra::Base
  register Sinatra::ConfigFile
  config_file "config.yml"

  configure do
    set :sessions, true
    enable :method_override
  end

  helpers do
    def set_status(osn_identifier)
      ipv4_status = Status.filter(
        osn_identifier.merge(:record_type => "ipv4_address")
      ).first
      @ipv4_address = ipv4_status.nil? ? "0.0.0.0" : ipv4_status.record

      txt_status = Status.filter(
        osn_identifier.merge(:record_type => "txt")
      ).first
      @txt = txt_status.nil? ? "" : txt_status.record

      @domain_name = "#{osn_identifier[:user_id]}.#{osn_identifier[:provider]}.#{settings.ddns_domain}"
    end
  end

  use OmniAuth::Builder do
    provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  end
  
  put "/status" do

  end

  get "/status" do
    @request_ip = request.ip

    haml :status
  end

  delete "/status" do
    haml :status
  end

  get "/auth/:provider/callback" do
    omniauth_result = request.env["omniauth.auth"]
    set_status(
      :provider => omniauth_result["provider"],
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
