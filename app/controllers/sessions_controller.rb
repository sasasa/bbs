# This controller handles the login/logout function of the site.  
class SessionsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  # 上書き 1 @current_user
  before_filter :login_required, :except=>[:new, :create]
  
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
    user = User.authenticate(params[:user][:login], params[:user][:password])
    if user
      # Protects against session fixation attacks, causes request forgery
      # protection if user resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      # reset_session
      self.current_user = user
      handle_remember_cookie! (params[:user][:remember_me] == "1")
      redirect_back_or_default(root_path)
      flash[:notice] = "ログインに成功しました"#"Logged in successfully"
    else
      note_failed_signin
      @user = User.new(:login=>params[:user][:login], :remember_me=>params[:user][:remember_me])
      render :action => 'new'
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
  # Track failed login attempts
  def note_failed_signin
    flash[:error] = "Couldn't log you in as '#{params[:user][:login]}'"
    logger.warn "Failed login for '#{params[:user][:login]}' from #{request.remote_ip} at #{Time.now.utc}"
  end
  # 2
  def check_valid_user
  end
end
