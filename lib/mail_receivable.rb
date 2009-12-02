# To change this template, choose Tools | Templates
# and open the template in the editor.

module MailReceivable
  # 回答通知メール(receive_mail)の文字列表現マスタ
  # フォームを作る
  RECEIVE_MAILS_ORDER = [[ALWAYS_RECEIVE = true, "随時受信"],[NO_RECEIVE = false, "受信しない"]].map(&:reverse)
  RECEIVE_MAILS = Hash[*RECEIVE_MAILS_ORDER.map(&:reverse).flatten]

  def self.included(recipient)
    recipient.extend(ModelClassMethods)
    recipient.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
  end # instance methods
end
