class UserObserver < ActiveRecord::Observer
  def after_create(user)
    UserMailer.deliver_signup_notification(user) if user.email
  end

  def after_save(user)
    UserMailer.deliver_activation(user) if user.email && user.recently_activated?
  end
end
