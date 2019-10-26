# frozen_string_literal: true

module UserRoles
  extend ActiveSupport::Concern

  included do
    scope :admins, -> { where(admin: true) }
    scope :moderators, -> { where(moderator: true) }
    scope :staff, -> { admins.or(moderators) }
  end

  def staff?
    admin? || moderator?
  end

  def role=(value)
    case value
    when 'admin'
      self.admin     = true
      self.moderator = false
    when 'moderator'
      self.admin     = false
      self.moderator = true
    else
      self.admin     = false
      self.moderator = false
    end
  end

  def role
    if admin?
      'admin'
    elsif moderator?
      'moderator'
    else
      'user'
    end
  end

  def role?(role)
    case role
    when 'user'
      true
    when 'moderator'
      staff?
    when 'admin'
      admin?
    else
      false
    end
  end

  def promote!
    if moderator?
      update!(moderator: false, admin: true)
    elsif !admin?
      update!(moderator: true)
    end
  end

  def demote!
    if admin?
      update!(admin: false, moderator: true)
    elsif moderator?
      update!(moderator: false)
    end
  end
end
