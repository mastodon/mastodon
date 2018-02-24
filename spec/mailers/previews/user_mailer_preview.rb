# Preview all emails at http://localhost:3000/rails/mailers/user_mailer

class UserMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/confirmation_instructions
  def confirmation_instructions
    UserMailer.confirmation_instructions(User.first, 'spec')
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/email_changed
  def email_changed
    user = User.first
    user.unconfirmed_email = 'foo@bar.com'
    UserMailer.email_changed(user)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/password_change
  def password_change
    UserMailer.password_change(User.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/reconfirmation_instructions
  def reconfirmation_instructions
    user = User.first
    user.unconfirmed_email = 'foo@bar.com'
    UserMailer.confirmation_instructions(user, 'spec')
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/reset_password_instructions
  def reset_password_instructions
    UserMailer.reset_password_instructions(User.first, 'spec')
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/welcome
  def welcome
    UserMailer.welcome(User.first)
  end

  # Preview this email at http://localhost:3000/rails/mailers/user_mailer/backup_ready
  def backup_ready
    UserMailer.backup_ready(User.first, Backup.first)
  end
end
