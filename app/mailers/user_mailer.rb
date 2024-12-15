class UserMailer < ApplicationMailer
  default from: 'no-reply@example.com'

  def recovery_email(email, recovery_code)
    @recovery_code = recovery_code
    mail(to: email, subject: 'Your Account Recovery Code')
  end
end
