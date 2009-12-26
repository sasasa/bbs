class ApplicationController < ActionController::Base

  helper :all # include all helpers, all the time
  trans_sid :mobile
  protect_from_forgery # See ActionController::RequestForgeryProtectionfor details
  include AuthenticatedSystem
  include ExceptionNotifiable
  include SslRequirement #0 before_filter :ensure_proper_protocol
  extend ActiveSupport::Memoizable

  # モバイルのIPチェック 1
  before_filter :valid_mobile_check

  # ログインチェック 2 @current_user
  # サブクラスで上書きしたり順番を入れ替えても必ず2番目に実行される ※2回実行されるため結果をmemoize
  before_filter :login_required

  # ログインIDを持っているかチェック 3
  # OpenID認証の時はログインしていてもログインIDを持たないためログインIDを入れるまで利用できないようにする ※2回実行されるため結果をmemoize
  before_filter :login_id_required

  # 操作権限チェック 4
  # サブクラスで上書きしたり順番を入れ替えても必ず4番目に実行される ※2回実行されるため結果をオーバーライド先でmemoize
  before_filter :check_valid_user

  # パンくず作成 5  @category @topic_path
  # サブクラスで上書きしたり順番を入れ替えても必ず5番目に実行される
  before_filter :create_topic_path

  after_filter :delete_space

  protected

  # モバイルからの正しいアクセスかどうかチェックする
  def valid_mobile_check
    logger.debug "filter1 valid_mobile_check"

    if request.mobile?
      # リクエストヘッダーなどはモバイルでもIPが正しくない場合
      # ヘッダー偽装攻撃またはキャリアのIP帯域が変更になった可能性がある
      unless request.mobile.valid_ip?
        mobile_logger_warn
        render '/common/not.html.erb'
        return false
      end

      # クッキーをサポートしていないときはquery_stringによる
      # 透過セッションとなる。query_stringはブラウザで自分で設定できてしまうので32文字とする
      unless request.mobile.supports_cookie?
        # ... ?session_key=session_id&param1=value1&param2=value2
        #session_key
        sess_key = (request.session_options ||
        ActionController::Base.session_options)[:key]
        logger.debug "session_key : " + sess_key
        #session_id
        session_id = params[sess_key]
        logger.debug "session_value : " + (session_id.nil? ? "nil" : session_id)
        # session_idがnilのときは新しいセッションが始まるとき
        if (!session_id.nil? && session_id.size != 32)
          mobile_logger_warn
          render '/common/not.html.erb'
          return false
        end
      end
    else
      # PCのときはチェックしない
      true
    end
  end

  # ログインIDを持っているかチェック 3
  def login_id_required
    logger.debug "filter3 login_id_required"
    return false unless current_user #ログインしていないときはチェックしない
    redirect_to new_login_users_path unless ret = !!current_user && !!current_user.login #ログインしていてloginIDがない時のみ
    ret
  end
  memoize :login_required
  memoize :login_id_required

  # 各サブクラスでオーバーライド 4
  def check_valid_user
    logger.debug "filter4 check_valid_user"
    raise
  end
  # パンくず作成  5 @category @topic_path
  # 満たない部分はオーバーライドして@topic_pathに追加していく
  # @topic_pathの構造 [[text1, path1],[text2, path2]]
  def create_topic_path
    logger.debug "filter5 create_topic_path => @category @topic_path"
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

  # 末端カテゴリのみ操作可能とする 6 @category
  def check_most_underlayer_category
    logger.debug "filter6 check_most_underlayer_category => @category"
    @category ||= Category.cache_find(params[:category_id])
    raise "filter6" unless @category.is_most_underlayer
  end
  
  # htmlの崩れを防止するため改行やスペースを削除
  def delete_space
    logger.debug "after delete_space"
    response.body.gsub!(/[\r\n]+/,"")
    response.body.gsub!(/>[　\s]+</,"><")
  end

  def mobile_logger_warn
    # ident_subscriberは
    # docomo => iモードID なければ FOMAカード製造番号(UIM)(icc + 20桁英数)
    # au => EZ番号(サブスクライバID)(14桁数値_2桁英数.ezweb.ne.jp)
    # softbank => ユーザID(UID)(16桁英数)
    # EMOBILE => EMnet対応端末から通知されるユニークなユーザID
    # ident_deviceは
    # docomo => FOMA端末製造番号(ser + 15桁英数) MOBA端末製造番号(ser + 11桁英数)
    # softbank => 製造番号(端末シリアル) P(11桁英数) W(15桁英数) 3GC(20桁英数)
    logger.warn "Failed valid_mobile_check for " +
    "carrier=>#{request.mobile.class.name.split(/::/).last }, " +
    "ident_subscriber=>#{request.mobile.ident_subscriber}, " +
    "ident_device=>#{request.mobile.ident_device}, " +
    "from #{request.remote_ip} at #{Time.now.utc}"
  end

  # 自サイトの一つ前のページに戻れるようにsessionに覚えておく
  def store_referer_location
    # 自サイト内で元いた場所を覚えておく処理
    if session[:return_to].blank? && !request.referer.blank? && request.referer =~ %r|^https?://#{request.raw_host_with_port}(/?.*)|
      session[:return_to] = $1
    end
  end
end
