# == Schema Information
# Schema version: 20091108170711
#
# Table name: answers
#
#  id                 :integer(4)      not null, primary key
#  content            :text
#  supplement_comment :text
#  thanks_comment     :text
#  url                :string(255)
#  kind               :integer(4)
#  confidence         :integer(4)
#  character          :integer(4)
#  receive_mail       :boolean(1)
#  user_id            :integer(4)
#  question_id        :integer(4)
#  created_at         :datetime
#  updated_at         :datetime
#

class Answer < ActiveRecord::Base
  include ShowFieldsOmitable
  include MailReceivable
  include AttrRelatedMethodDefinable

  # 回答の種類(kind)の文字列表現マスタ
  # フォームを作る際とバリデーションで利用する
  KINDS_ORDER = [[ADVICE = 1,"アドバイス"],[REPLY = 2,"回答"],[SUPPLEMNET_REQUEST = 3,"補足要求"]]
  KINDS = Hash[*KINDS_ORDER.flatten]
  
  # 回答に対する自信(confidence)の文字列表現マスタ
  # フォームを作る際とバリデーションで利用する
  COMFIDENCES_ORDER = [[HIGH_COMFIDENCE = 1,"自信あり"],[CONSULT_COMFIDENCE = 2,"参考意見"],[LOW_COMFIDENCE = 3,"自信なし"]]
  COMFIDENCES = Hash[*COMFIDENCES_ORDER.flatten]

  # あなたはどんな人(character)の文字列表現マスタ
  # フォームを作る際とバリデーションで利用する
  CHARACTERS_ORDER = [[SPECIALIST = 1, "専門家"],[EXPERIENCED = 2, "経験者"],[GENERAL = 3, "一般人"]].map(&:reverse)
  CHARACTERS = Hash[*CHARACTERS_ORDER.map(&:reverse).flatten]

  acts_as_cached right_ttl

  # デフォルトの値を設定 kind_default_val
  attr_default_val :kind=>REPLY, :confidence=>CONSULT_COMFIDENCE, :character=>GENERAL, :receive_mail=>ALWAYS_RECEIVE

  # インスタンスからアクセスできるマスタ kind_mst
  attr_mst :kind=>KINDS_ORDER, :confidence=>COMFIDENCES_ORDER, :character=>CHARACTERS_ORDER, :receive_mail=>RECEIVE_MAILS_ORDER

  # 文字列表現 kind_text
  attr_text :kind=>KINDS, :confidence=>COMFIDENCES, :character=>CHARACTERS, :receive_mail=>RECEIVE_MAILS

  validates_presence_of     :content, :kind, :confidence, :character
  validates_length_of       :content,   :within => 25..2000,   :allow_blank => true
  validates_length_of       :supplement_comment, :thanks_comment,
                                            :within => 25..2000, :allow_blank => true
  validates_length_of       :url,        :within => 14..255,   :allow_blank => true
  validates_inclusion_of    :kind,       :in=>KINDS.keys ,     :allow_blank => true
  validates_inclusion_of    :confidence, :in=>COMFIDENCES.keys,:allow_blank => true
  validates_inclusion_of    :character,  :in=>CHARACTERS.keys, :allow_blank => true

  # 安全に倒してホワイトリストとするためカラム追加時に忘れないこと
  # 複数の権限から扱われるデータの際は一番低い権限に合わせる
  attr_accessible :content, :url, :kind, :confidence, :character, :receive_mail

  belongs_to :user
  belongs_to :question

end
