# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem
  include ExceptionNotifiable
  include SslRequirement #before_filter :ensure_proper_protocol 1
  extend ActiveSupport::Memoizable
  # ログインチェック 1 @current_user
  # サブクラスで上書きしたり順番を入れ替えても必ず1番目に実行される ※2回実行されるため結果をmemoize
  before_filter :login_required

  # ログインIDを持っているかチェック 1.5
  # OpenID認証の時はログインしていてもログインIDを持たないためログインIDを入れるまで利用できないようにする ※2回実行されるため結果をmemoize
  before_filter :login_id_required

  # 操作権限チェック 2
  # サブクラスで上書きしたり順番を入れ替えても必ず2番目に実行される ※2回実行されるため結果をオーバーライド先でmemoize
  before_filter :check_valid_user
  
  # パンくず作成 3  @category @topic_path
  # サブクラスで上書きしたり順番を入れ替えても必ず3番目に実行される
  before_filter :create_topic_path

  # htmlの崩れを防止するため改行やスペースを削除 1
  after_filter :delete_space #if RAILS_ENV=="production"

protected
  # ログインIDを持っているかチェック 1.5
  def login_id_required
    logger.debug "filter1.5 login_id_required"
    return false unless current_user #ログインしていないときはチェックしない
    redirect_to new_login_users_path unless ret = !!current_user && !!current_user.login #ログインしていてloginIDがない時のみ
    ret
  end
  memoize :login_required
  memoize :login_id_required
  
  # 各サブクラスでオーバーライド 2
  def check_valid_user
    logger.debug "filter2 check_valid_user"
    raise
  end

  # パンくず作成  3 @category @topic_path
  # 満たない部分はオーバーライドして@topic_pathに追加していく
  # @topic_pathの構造 [[text1, path1],[text2, path2]]
  def create_topic_path
    logger.debug "filter3 create_topic_path => @category @topic_path"
    @category = Category.cache_find(params[:category_id]) if params[:category_id]
    @category = Category.cache_find(params[:id]) if @category.blank? && controller_name == "categories" && params[:id]
    @topic_path = []
    if @category
      @topic_path << @category
      @topic_path += @category.cache_ancestors
      @topic_path.reverse!
      @topic_path.map! do |obj|
        if obj.is_most_underlayer
          session[:page] = params[:page] unless params[:page].blank?
          session[:page] = "1" if session[:page].blank?
          [obj.name + "【#{session[:page]}】", category_questions_path(obj, :page=>session[:page])]
        else
          [obj.name, category_path(obj)]
        end
      end
    end
    @topic_path.dup
  end

  # 末端カテゴリのみ操作可能とする 4 @category
  def check_most_underlayer_category
    logger.debug "filter4 check_most_underlayer_category => @category"
    @category ||= Category.cache_find(params[:category_id])
    raise "filter4" unless @category.is_most_underlayer
  end

  # htmlの崩れを防止するため改行やスペースを削除 1
  def delete_space
    if response.body
      logger.debug "after filter1 delete_space"
      response.body.gsub!(/[\r\n]+/,"")
      response.body.gsub!(/>[　\s]+</,"><")#半角空白ミスで入り込む可能性が有る全角空白
    end
  end
end