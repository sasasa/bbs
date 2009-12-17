# == Schema Information
# Schema version: 20091108170711
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
#

require 'digest/sha1'

class User < ActiveRecord::Base
  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::AasmRoles
  include ShowFieldsOmitable

  acts_as_cached right_ttl

  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => "は英数値と.-_@のみで入力してください。"#Authentication.bad_login_message
  
  #OpenID認証でなくログイン認証の時のみバリデーションする(identity_urlがない場合)
  with_options :unless=>lambda{ |u| u.identity_url } do |user|
    user.validates_format_of       :name,     :with => Authentication.name_regex, :message => "は表示可能な文字のみで入力してください。"#Authentication.bad_name_message, :allow_nil => true
    user.validates_length_of       :name,     :maximum => 100

    user.validates_presence_of     :email
    user.validates_length_of       :email,    :within => 6..100 #r@a.wk
    user.validates_uniqueness_of   :email
    user.validates_format_of       :email,    :with => Authentication.email_regex, :message => "はメールの形式で入力してください。"#Authentication.bad_email_message

    user.validates_presence_of     :password,                   :if => :password_required?
    user.validates_presence_of     :password_confirmation,      :if => :password_required?
    user.validates_confirmation_of :password,                   :if => :password_required?
    user.validates_length_of       :password, :within => 6..40, :if => :password_required?
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

  protected
    def make_activation_code
      self.deleted_at = nil
      self.activation_code = self.class.make_token
    end
end
