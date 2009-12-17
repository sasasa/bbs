class SessionsController < ApplicationController
  # 上書き 1 @current_user
  before_filter :login_required, :except=>[:new, :create, :show]
  # ログインIDを持っているかチェック 1.5
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
    if session[:return_to].blank? && !request.referer.blank? && request.referer =~ %r|^https?://#{HOSTNAME}|
      session[:return_to] = request.referer
    end
    @user = User.new
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
  
  # /logout 
  # DELETE /session
  def destroy
    logout_killing_session!
    flash[:notice] = "ログアウトしました"#"You have been logged out."
    redirect_back_or_default(request.referer || root_path)
  end

protected
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
    proc.call if proc
  end

  # OpenIDのときとパスワード認証で失敗の時に呼ばれる
  def auth_failed(opt={})
    # ログインに失敗
    note_failed_signin(opt[:login] || opt[:openid_url] || "OP_ERROR")
    flash[:notice] = "ログインに失敗しました"
    @user = User.new(opt)
    render 'new'
  end

  # Track failed login attempts
  def note_failed_signin(ident)
    flash[:error] = "Couldn't log you in as '#{ident}'"
    logger.warn "Failed login for '#{ident}' from #{request.remote_ip} at #{Time.now.utc}"
  end

  # 2
  def check_valid_user
    logger.debug "filter2 check_valid_user"
  end
end
