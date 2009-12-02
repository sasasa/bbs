class UserMailer < ActionMailer::Base
  def signup_notification(user)
    setup_email(user)
    @subject    += "アクティベーションを行ってください"#'Please activate your new account'
    @body[:url]  = activate_url(:host=>HOSTNAME, :activation_code=>user.activation_code)
  end
  
  def activation(user)
    setup_email(user)
    @subject    += "アクティベーションが完了しました"#'Your account has been activated!'
    @body[:url]  = login_url(:host=>HOSTNAME)
  end
  
  protected
    def setup_email(user)
      @recipients  = "#{user.email}"
      @from        = "Question*Answer@hotmail.co.jp"
      @subject     = "Question*Answerの運営より重要なお知らせです。"
      @sent_on     = Time.now
      @body[:user] = user
    end
end
