# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details
  include AuthenticatedSystem

  # ログインチェック 1 @current_user
  # サブクラスで上書きしたり順番を入れ替えても必ず1番目に実行される
  before_filter :login_required

  # 操作権限チェック 2
  # サブクラスで上書きしたり順番を入れ替えても必ず2番目に実行される
  before_filter :check_valid_user
  
  # パンくず作成 3  @category @topic_path
  # サブクラスで上書きしたり順番を入れ替えても必ず3番目に実行される
  before_filter :create_topic_path

  after_filter :delete_space #if RAILS_ENV=="production"

protected
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
    @category = Category.find(params[:category_id]) if params[:category_id]
    @category = Category.find(params[:id]) if @category.blank? && controller_name == "categories" && params[:id]
    @topic_path = []
    if @category
      @topic_path << @category
      @topic_path += @category.ancestors
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
  end

  # 末端カテゴリのみ操作可能とする 4 @category
  def check_most_underlayer_category
    logger.debug "filter4 check_most_underlayer_category => @category"
    @category ||= Category.find(params[:category_id])
    raise "filter4" unless @category.is_most_underlayer
  end

  # htmlの崩れを防止するため改行やスペースを削除
  def delete_space
    logger.debug "after delete_space"
    response.body.gsub!(/\n/,"")
    response.body.gsub!(/>\s+</,"><")
  end
end