class SessionsController < ApplicationController
  ssl_required :new, :show, :create

  # 上書き 2 @current_user
  before_filter :login_required, :except=>[:new, :create, :show, :mobile_create]
  # ログインIDを持っているかチェック 3
  before_filter :login_id_required, :except=>[:destroy]

  # GET   /session OPからのredirect
  def show
    # OpenID による認証 complete
    open_id_complete
  end

  # /login
  # GET    /session/new
  def new
    # 自サイト内で元いた場所を覚えておく処理
    store_referer_location
    @user = User.new
  end

  # POST /mobile_create
  # POST /mobile_auth
  def mobile_create
    logout_keeping_session!
    # 簡単ログインによる認証
    mobile_authentication
  end

  # POST   /session
  def create
    logout_keeping_session!
    if openid_url = params[:user][:openid_url] # OpenID による認証 begin
      open_id_begin(openid_url)
    else
      # パスワードによる認証
      password_authentication
    end
  end

    module ActionController
      class Request

      end
    end
  
  # /logout 
  # DELETE /session
  def destroy
    store_referer_location
    logout_keeping_session!
    flash[:notice] = "ログアウトしました"#"You have been logged out."

    #sessionを完全に消せないかどうかを確認する
    request.regenerate_session

    #redirect_back_or_default(request.referer || root_path)
    redirect_back_or_default(root_path)
  end

protected
  def mobile_authentication
    if request.mobile?
      carrier = request.mobile.carrier_name
      mobile_ident = request.mobile.ident_subscriber || request.mobile.ident_device
      if user = User.mobile_authenticate(carrier, mobile_ident)
        # 識別情報がマッチしたとき
        login_success(user){ redirect_back_or_default(root_path) }
      elsif carrier && mobile_ident
        user = User.new.set_attrs(:carrier=>User.mobile_carrier_num_from_name(carrier), :mobile_ident=>mobile_ident)
        user.save(false)
        # ログインには成功したが, 識別情報が新規でアカウントを所有していない
        login_success(user) do
          flash[:notice] = flash[:notice] + "次回以降簡単にログインできます。"
          redirect_to new_login_users_path
        end
      else
        # 識別情報を送信しないとき
        mobile_logger_warn
        auth_failed{ flash.now[:notice] = flash.now[:notice] + "識別情報を送信してください。" }
      end
    else
      # 携帯でないとき
      auth_failed
    end
  end

  def password_authentication
    if user = User.authenticate(params[:user][:login], params[:user][:password])
      login_success(user){ redirect_back_or_default(root_path) }
    else
      auth_failed(:login=>params[:user][:login], :remember_me=>params[:user][:remember_me])
    end
  end

  def open_id_begin(openid_url)
    begin_open_id_authentication openid_url do |result, identity_url, sreg|
      auth_failed(:openid_url=>openid_url) if result.unsuccessful?
    end
  end
  
  def open_id_complete
    complete_open_id_authentication do |result, identity_url, sreg|
      if result.unsuccessful?
        auth_failed
      else
        user = User.find_by_identity_url(identity_url)
        if user && user.login
          # ログインに成功し, すでにアカウントがある
          login_success(user){ redirect_back_or_default(root_path) }
        else
          unless user
            user = User.new(:identity_url=>identity_url)
            user.save(false)
          end
          # ログインには成功したけど, アカウントを所有していない
          login_success(user){ redirect_to new_login_users_path }
        end
      end
    end
  end

  # OpenIDのときとパスワード認証で成功の時に呼ばれる
  # 前処理と後処理を指定する
  def login_success(user, &proc)
    self.current_user = user #ここで@current_userが作成、ユーザIDがsessionに入る
    handle_remember_cookie!(params[:user][:remember_me] == "1") if params[:user]
    flash[:notice] = "ログインに成功しました"#"Logged in successfully"

    #sessionを完全に消せないかどうかを確認する
    request.regenerate_session
    proc.call if proc
  end

  # OpenIDのときとパスワード認証で失敗の時に呼ばれる
  def auth_failed(opt={}, &proc)
    # ログインに失敗
    note_failed_signin(opt[:login] ||
                       opt[:openid_url] ||
                       request.mobile? && /#{Regexp.quote(mobile_auth_path)}/ =~ request.request_uri ? "mobile_error" : "OP_ERROR")
    flash[:notice] = "ログインに失敗しました"
    proc.call if proc
    @user = User.new(opt)
    render 'new'
  end

  # Track failed login attempts
  def note_failed_signin(ident)
    flash[:error] = "Couldn't log you in as '#{ident}'"
    logger.warn "Failed login for '#{ident}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  # 4
  def check_valid_user
    logger.debug "filter4 check_valid_user"
  end
end
