class UsersController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  include AuthenticatedSystem
  
  # Protect these actions behind an admin login
  # before_filter :admin_required, :only => [:suspend, :unsuspend, :destroy, :purge]
  # 上書き 1 @current_user
  before_filter :login_required,   :except=>[:new, :create, :activate ]
  # 上書き 2 @user
  before_filter :check_valid_user, :except=>[:new, :create, :activate, :new_login, :create_login]

  # GET    /users/new_login
  def new_login
  end

  # POST   /users/create_login
  def create_login
    current_user.login = params[:user][:login]
    current_user.valid?
    fail = current_user.errors.invalid?('login')
    #ログインIDのみチェックする
    if fail
      render 'new_login'
    else
      current_user.save(false)
      flash[:notice] = "ログイン名を登録しました。"
      redirect_back_or_default(root_path)
    end
  end

  # /signup
  # GET    /users/new
  def new
    @user = User.new
  end

  # /register
  # POST   /users
  def create
    logout_keeping_session!
    @user = User.new(params[:user])

    @user.register! if @user && @user.valid?
    success = @user && @user.valid?

    if success && @user.errors.empty?
      flash[:notice] = "登録いただいたアドレスにメールを送信しましたのでご確認下さい。"#"Thanks for signing up!  We're sending you an email with your activation code."
      redirect_back_or_default(root_path)
    else
      @user.password = @user.password_confirmation = nil
      flash[:error]  = "We couldn't set up that account, sorry.  Please try again, or contact an admin (link is above)."
      render 'new'
    end
  end

  # /activate/:activation_code
  def activate
    logout_keeping_session!
    user = User.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && user && !user.active?
      user.activate!
      flash[:notice] = "アクティベーション登録が完了しました。ログインしてください。"#"Signup complete! Please sign in to continue."
      redirect_to login_path
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default(root_path)
    else 
      flash[:error]  = "We couldn't find a user with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default(root_path)
    end
  end

  # PUT    /users/:id/suspend
  def suspend
    @user.suspend! 
    redirect_to users_path
  end

  # PUT    /users/:id/unsuspend
  def unsuspend
    @user.unsuspend! 
    redirect_to users_path
  end

  # DELETE /users/:id
  def destroy
    @user.delete!
    redirect_to users_path
  end

  # DELETE /users/:id/purge
  def purge
    @user.destroy
    redirect_to users_path
  end
  
  # There's no page here to update or destroy a user.  If you add those, be
  # smart -- make sure you check that the visitor is authorized to do so, that they
  # supply their old password along with a new one to update it, etc.

protected
  # 2 @user
  def check_valid_user
    @user = User.find(params[:id])
    raise "filter2" unless @user.id == current_user.id
  end
end
