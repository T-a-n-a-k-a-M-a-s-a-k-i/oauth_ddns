class WebService < Sinatra::Base
  register Sinatra::ConfigFile
  config_file "config.yml"

  configure do
    set :layout_engine => :haml
    enable :method_override
    enable :sessions
  end

  helpers do
    def get_ipv4_address
      ipv4_status = Status.find(
        :uid => session[:uid],
        :record_type => "ipv4_address"
      )
      ipv4_status.nil? ? "0.0.0.0" : ipv4_status.record
    end

    def get_txt
      txt_status = Status.find(
        :uid => session[:uid],
        :record_type => "txt"
      )
      txt_status.nil? ? "" : txt_status.record
    end

    def get_dns_vital
      vital = Status.find(
        :uid => session[:uid],
        :record_type => "ipv4_address"
      ).nil? ? "halt" : "activate"
    end

    def authenticated?
      !session[:uid].nil?
    end
  end

  before do
    pass if request.path_info == "/"
    pass if request.path_info =~ /^\/auth\//

    redirect to("/") unless authenticated?
  end

  use OmniAuth::Builder do
    provider :twitter, settings.twitter_key, settings.twitter_secret
  end
  
  put "/status" do
    Status.update_status(params.merge(
      "uid" => session[:uid],
      "ipv4_address" => request.ip
    ))

    redirect to("/status")
  end

  get "/status" do
    user_account = UserAccount.find(:uid => session[:uid])
    
    @request_ip = request.ip
    @domain_name = "#{user_account.nickname}.#{user_account.provider}.#{settings.ddns_domain}"
    @dns_vital = get_dns_vital()
    @ipv4_address = get_ipv4_address()
    @txt = get_txt()

    haml :status
  end

  delete "/status" do
    Status.delete_status(session[:uid])

    redirect to("/status")
  end

  get "/auth/:provider/callback" do
    omniauth_result = request.env["omniauth.auth"]
    session[:uid] = omniauth_result["uid"]

    UserAccount.find_or_create(
      :uid => session[:uid],
      :provider => omniauth_result["provider"],
      :nickname => omniauth_result["info"]["nickname"]
    )

    redirect to("/status")
  end

  put "/api/status" do

  end

  delete "/api/status" do

  end

  get "/" do
    haml :index
  end
end
