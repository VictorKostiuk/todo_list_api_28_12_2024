class ApplicationMailer < ActionMailer::Base
  default from: "no-reply@todo-api.com"
  layout "mailer"
end
