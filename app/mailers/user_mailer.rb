class UserMailer < ApplicationMailer
  def task_email(user)
    sleep 10
    @user = user
    mail(to: @user.email, subject: "Task created!")
  end
end