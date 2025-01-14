# frozen_string_literal: true

module Status::Visibility
  extend ActiveSupport::Concern

  DISTRIBUTABLE_VISIBILITIES = %w(public unlisted).freeze
  UNRESTRICTED_VISIBILITIES = %w(public unlisted private).freeze

  included do
    enum :visibility,
         { public: 0, unlisted: 1, private: 2, direct: 3, limited: 4 },
         suffix: :visibility,
         validate: true

    scope :distributable_visibility, -> { where(visibility: DISTRIBUTABLE_VISIBILITIES) }
    scope :unrestricted_visibility, -> { where(visibility: UNRESTRICTED_VISIBILITIES) }
    scope :not_direct_visibility, -> { where.not(visibility: :direct) }

    validates :visibility, inclusion: { in: UNRESTRICTED_VISIBILITIES }, if: :reblog?

    before_validation :set_visibility, unless: :visibility?
  end

  def hidden?
    !distributable?
  end

  def distributable?
    public_visibility? || unlisted_visibility?
  end

  alias sign? distributable?

  private

  def set_visibility
    self.visibility ||= reblog.visibility if reblog?
    self.visibility ||= visibility_from_account
  end

  def visibility_from_account
    account.locked? ? :private : :public
  end
end
