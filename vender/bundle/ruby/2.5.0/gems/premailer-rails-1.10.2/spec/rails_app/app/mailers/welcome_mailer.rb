class WelcomeMailer < ApplicationMailer
  def welcome_email(greeting)
    @greeting = greeting
    mail to: "example@example.com"
  end
end
