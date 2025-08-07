# frozen_string_literal: true

# Additional User Input Validation and Security Enhancement
class SecurityValidatorsConcern
  extend ActiveSupport::Concern

  included do
    # Add additional security validations
    validate :validate_strong_password, if: :password_required?
    validate :validate_no_common_passwords, if: :password_required?
    validate :validate_username_not_admin_like, if: -> { username.present? && local? }
    validate :validate_email_not_suspicious, if: -> { email.present? }
    validate :validate_display_name_not_malicious, if: -> { display_name.present? }
  end

  private

  def validate_strong_password
    return unless password.present?

    errors.add(:password, 'must contain at least one uppercase letter') unless password.match?(/[A-Z]/)
    errors.add(:password, 'must contain at least one lowercase letter') unless password.match?(/[a-z]/)
    errors.add(:password, 'must contain at least one digit') unless password.match?(/\d/)
    errors.add(:password, 'must contain at least one special character') unless password.match?(/[^A-Za-z0-9]/)
    errors.add(:password, 'must be at least 12 characters long') if password.length < 12
    errors.add(:password, 'cannot be longer than 128 characters') if password.length > 128
  end

  def validate_no_common_passwords
    return unless password.present?

    common_passwords = %w[
      password password123 123456 12345678 qwerty admin administrator
      welcome login mastodon social network federated fediverse
    ]
    
    if common_passwords.any? { |common| password.downcase.include?(common) }
      errors.add(:password, 'cannot contain common password patterns')
    end
  end

  def validate_username_not_admin_like
    admin_like_patterns = %w[
      admin administrator root superuser mod moderator owner webmaster
      support security system official mastodon staff ops devops
    ]
    
    if admin_like_patterns.any? { |pattern| username.downcase.include?(pattern) }
      errors.add(:username, 'cannot contain administrative terms')
    end
  end

  def validate_email_not_suspicious
    # Check for suspicious email patterns
    suspicious_patterns = [
      /\+.*admin/i,
      /\+.*root/i,
      /\+.*test/i,
      /noreply/i,
      /no-reply/i,
      /donotreply/i,
      /postmaster/i
    ]

    if suspicious_patterns.any? { |pattern| email.match?(pattern) }
      errors.add(:email, 'contains suspicious patterns')
    end

    # Check for disposable email domains
    disposable_domains = %w[
      10minutemail.com guerrillamail.com mailinator.com temp-mail.org
      throwaway.email tempmail.com sharklasers.com yopmail.com
    ]

    email_domain = email.split('@').last&.downcase
    if disposable_domains.include?(email_domain)
      errors.add(:email, 'from disposable email provider not allowed')
    end
  end

  def validate_display_name_not_malicious
    # Check for potential XSS or malicious content in display name
    malicious_patterns = [
      /<script/i,
      /javascript:/i,
      /data:text\/html/i,
      /vbscript:/i,
      /on\w+\s*=/i, # onclick, onload, etc.
      /expression\s*\(/i
    ]

    if malicious_patterns.any? { |pattern| display_name.match?(pattern) }
      errors.add(:display_name, 'contains potentially malicious content')
    end

    # Check for excessive special characters (potential for confusable characters)
    special_char_ratio = display_name.scan(/[^\w\s]/).length.to_f / display_name.length
    if special_char_ratio > 0.5
      errors.add(:display_name, 'contains too many special characters')
    end
  end
end

# Apply to User model
User.class_eval do
  include SecurityValidatorsConcern
end

# Apply to Account model
Account.class_eval do
  include SecurityValidatorsConcern
end
