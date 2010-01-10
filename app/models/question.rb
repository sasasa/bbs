# == Schema Information
# Schema version: 20100106152908
#
# Table name: questions
#
#  id           :integer(4)      not null, primary key
#  title        :string(255)
#  content      :text
#  state        :integer(4)
#  is_closed    :boolean(1)
#  receive_mail :boolean(1)      default(TRUE)
#  user_id      :integer(4)
#  category_id  :integer(4)
#  created_at   :datetime
#  updated_at   :datetime
#

class Question < ActiveRecord::Base
  include ShowFieldsOmitable
  include MailReceivable
  include AttrRelatedMethodDefinable

  # 困り度(state)の文字列表現マスタ
  # フォームを作る際とバリデーションで利用する
  STATES_ORDER = [[FREE_TIME = 1,"暇なときに回答ください"],[USUAL = 2,"困ってます"],[QUICK = 3,"すぐに回答ほしいです"]]
  STATES = Hash[*STATES_ORDER.flatten]

  acts_as_cached right_ttl

  # デフォルトの値を設定 state_default_val
  attr_default_val :state=>USUAL, :receive_mail=>ALWAYS_RECEIVE

  # インスタンスからアクセスできるマスタ state_mst
  attr_mst :state=>STATES_ORDER, :receive_mail=>RECEIVE_MAILS_ORDER

  # 文字列表現 state_text
  attr_text :state=>STATES, :receive_mail=>RECEIVE_MAILS

  validates_presence_of     :title, :content, :state
  validates_length_of       :title,    :within => 5..60 ,   :allow_blank => true
  validates_length_of       :content,  :within => 25..2000, :allow_blank => true
  validates_inclusion_of    :state,    :in=>STATES.keys,    :allow_blank => true
  validates_text            :content, :max_length_per_row=>60, :max_size_row=>100

  # 安全に倒してホワイトリストとするためカラム追加時に忘れないこと
  # 複数の権限から扱われるデータの際は一番低い権限に合わせる
  attr_accessible :title, :content, :state, :is_closed, :receive_mail

  belongs_to :category
  belongs_to :user
  has_many :answers, :dependent => :destroy, :order => 'created_at desc'

  named_scope :order_recent, :order => 'created_at desc'
  named_scope :include, :include=>[:user, :answers]
  named_scope :deep_include, :include=>[:user, {:answers=>:user}]
  named_scope :relate, lambda{|category| { :conditions => ['category_id = ?', category.id] } }

  # 紐づくanswersが増減で場合失効させる必要がある
  def self.cache_paginate_order_recent(category, current_page)
    self.get_cache("#{self}.cache_paginate_order_recent(#{category.id},#{current_page})") do
      self.relate(category).include.order_recent.paginate(:page => current_page, :per_page => 5)
    end
  end

  # 紐づくanswersが増減で失効させる必要がある
  def self.cache_deep_include_find(id)
    self.get_cache("#{self}.cache_deep_include_find(#{id})") do
      self.deep_include.find(id)
    end
  end
end
