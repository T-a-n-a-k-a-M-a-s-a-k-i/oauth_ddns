class WebService < Sinatra::Base
  register Sinatra::ConfigFile
  config_file "config.yml"

  configure do
    set :session_secret, settings.session_secret
    set :layout_engine => :haml
    enable :method_override
    enable :sessions
  end

  helpers do
    def set_osn_identifier(user_id, provider)
      @user_id = user_id
      @provider = provider
    end

    def create_new_status(record_type)
      status = Status.new(
        :user_id => @user_id,
        :provider => @provider,
        :record_type => record_type
      )
    end

    def update_status(params)
      ipv4_status = get_status("ipv4_address")
      ipv4_status ||= create_new_status("ipv4_address")
      ipv4_status.set(:record => params["ipv4_address"])

      txt_status = get_status("txt")
      txt_status ||= create_new_status("txt")
      txt_status.set(:record => params["txt"])

      DB.transaction do
        ipv4_status.save_changes(:raise_on_failure => true)
        txt_status.save_changes(:raise_on_failure => true)
      end
    end

    def delete_status
      ipv4_status = get_status("ipv4_address")
      txt_status = get_status("txt")

      DB.transaction do
        ipv4_status.delete if ipv4_status
        txt_status.delete if txt_status
      end
    end

    def get_status(record_type)
      status = Status.filter(
        :user_id => @user_id,
        :provider => @provider,
        :record_type => record_type
      ).first
    end

    def get_ipv4_address
      ipv4_address = get_status("ipv4_address").nil? ? "0.0.0.0" : ipv4_status.record
    end

    def get_txt
      txt = get_status("txt").nil? ? "" : txt_status.record
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
    provider :twitter, ENV["TWITTER_KEY"], ENV["TWITTER_SECRET"]
  end
  
  put "/status" do
    update_status(params.merge("ipv4_address" => request.ip))

    redirect to("/status")
  end

  get "/status" do
    @request_ip = request.ip
    @domain_name = "#{@user_id}.#{@provider}.#{settings.ddns_domain}"
    @ipv4_address = get_ipv4_address()
    @txt = get_txt()

    haml :status
  end

  delete "/status" do
    delete_status()
    session[:uid] = nil

    haml :status
  end

  get "/auth/:provider/callback" do
    omniauth_result = request.env["omniauth.auth"]
    session[:uid] = omniauth_result["uid"]
    set_osn_identifier(omniauth_result["info"]["nickname"], omniauth_result["provider"])

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
