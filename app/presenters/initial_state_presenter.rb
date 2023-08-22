# frozen_string_literal: true

class InitialStatePresenter < ActiveModelSerializers::Model
  attributes :settings, :push_subscription, :token,
             :current_account, :admin, :owner, :text, :visibility,
             :disabled_account, :moved_to_account, :critical_updates_pending

  def role
    current_account&.user_role
  end

  def critical_updates_pending
    role&.can?(:view_devops) && ENV['UPDATE_CHECK_URL'] != '' && SoftwareUpdate.where(urgent: true).to_a.any? { |update| update.gem_version > gem_version }
  end

  private

  def gem_version
    @gem_version ||= Gem::Version.new(Mastodon::Version.to_s.split('+')[0])
  end
end
