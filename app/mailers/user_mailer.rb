class UserMailer < ApplicationMailer
  def welcome_email(user)
    @user = user
    mail(to: @user.email_address, subject: "Welcome")
  end
end
