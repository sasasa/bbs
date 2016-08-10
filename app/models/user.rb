# == Schema Information
# Schema version: 20100106152908
#
# Table name: users
#
#  id                        :integer(4)      not null, primary key
#  login                     :string(40)
#  name                      :string(100)     default("")
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)     default("passive")
#  deleted_at                :datetime
#  identity_url              :string(255)
#  mobile_ident              :string(255)
#  carrier                   :integer(4)
#

require 'digest/sha1'

class User < ActiveRecord::Base
  # ここにコメント追加
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  include ShowFieldsOmitable
  include AttrRelatedMethodDefinable
  
  # キャリアの文字列表現マスタ
  # フォームを作る際とバリデーションで利用する
  CARRIERS_ORDER = [[DOCOMO = 1,"Docomo"],
                  [AU = 2,"Au"],
                  [SOFTBANK = 3,"Softbank"],
                  [VODAFONE = 4,"Vodafone"],
                  [JPHONE = 5,"Jphone"],
                  [EMOBILE = 6,"Emobile"],
                  [WILLCOM = 7,"Willcom"],
                  [DDIPOCKET = 8,"Ddipocket"]]
  CARRIERS = Hash[*CARRIERS_ORDER.map(&:reverse).flatten]

  # OpenIDの文字列表現マスタ
  # フォームを作る際とバリデーションで利用する
  OPENID_URL_NAMES_ORDER = [[YAHOO_URL = "1", "yahoo"],[MIXI_URL = "2", "mixi"],[GOOGLE_URL = "3", "google"]].map(&:reverse)
  # OpenIDのディスカバリで利用するURL
  OPENID_URLS_ORDER = [[YAHOO_URL, "yahoo.co.jp"],[MIXI_URL, "https://mixi.jp/"],[GOOGLE_URL, "https://www.google.com/accounts/o8/id"]]
  OPENID_URLS = Hash[*OPENID_URLS_ORDER.flatten]

  acts_as_cached right_ttl

  # デフォルトの値を設定 openid_url_default_val
  attr_default_val :openid_url=>YAHOO_URL

  # インスタンスからアクセスできるマスタ openid_url_mst
  attr_mst :openid_url=>OPENID_URL_NAMES_ORDER

  # 文字列表現 openid_url_text
  attr_text :openid_url=>OPENID_URLS

  validates_inclusion_of    :openid_url, :in=>OPENID_URLS.keys, :allow_nil => true
  validates_inclusion_of    :carrier,    :in=>CARRIERS.values,  :allow_nil => true

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => "は数値、文字と.-_@のみで入力してください。"
  
  #OpenID認証や簡単ログインでなくログイン認証の時のみバリデーションする
  with_options :if=>:validates_required? do |user|
    user.validates_format_of :name, :with => Authentication.name_regex, :message => "は表示可能な文字のみで入力してください。"
    user.validates_length_of :name, :maximum => 100

    user.validates_presence_of :email
    user.validates_length_of :email, :within => 6..100 #r@a.wk
    user.validates_uniqueness_of :email
    #user.validates_format_of :email, :with => Authentication.email_regex, :message => "はメールの形式で入力してください。"
    user.validates_email_veracity_of :email, :message => "はメールの形式で入力してください。",
                                             :timeout_message => 'は利用可能なメールアドレスを入力してください。', :timeout => 1, :fail_on_timeout => true
                                             #:invalid_domain_message => 'は使わせへんで', :invalid_domains => ["google.com", "yahoo.co.jp"]

    user.with_options :if=>lambda{ |u| u.validates_required? && u.password_required? } do |user_pass|
      user_pass.validates_presence_of :password
      user_pass.validates_presence_of :password_confirmation
      user_pass.validates_confirmation_of :password
      user_pass.validates_length_of :password, :within => 6..40
    end
  end

  # 安全に倒してホワイトリストとするためカラム追加時に忘れないこと
  # 複数の権限から扱われるデータの際は一番低い権限に合わせる
  attr_accessible :login, :email, :name, :password, :password_confirmation, :remember_me, :openid_url, :identity_url
  attr_accessor :password, :remember_me, :openid_url

  has_many :questions, :dependent => :nullify, :order => 'created_at'
  has_many :answers, :dependent => :nullify, :order => 'created_at'
  
  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_in_state :first, :active, :conditions => {:login => login.downcase} # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def self.mobile_authenticate(carrier, mobile_ident)
    return nil if carrier.blank? || mobile_ident.blank?
    find_by_mobile_ident_and_carrier(mobile_ident, mobile_carrier_num_from_name(carrier))
  end

  def self.mobile_carrier_num_from_name(carrier)
    return nil if carrier.blank?
    CARRIERS[carrier]
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  # OpenIDでの登録の場合はloginがnilの場合がある
  def display_login_name
    login_was ? login : "名無し"
  end

  # OpenID認証のときと簡単ログインの時はバリデーションする必要がない
  def validates_required?
    (!identity_url && !carrier && !mobile_ident)
  end

  protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
end
