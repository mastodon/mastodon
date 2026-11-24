# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_capabilities
#
#  id               :bigint(8)        not null, primary key
#  enabled          :boolean          default(FALSE), not null
#  name             :string           not null
#  version          :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fasp_provider_id :bigint(8)        not null
#
class Fasp::Capability < ApplicationRecord
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'

  before_update :update_remote_capability

  def major_version
    version.split('.').first
  end

  private

  def update_remote_capability
    return unless enabled_changed?

    path = "/capabilities/#{name}/#{major_version}/activation"
    if enabled?
      Fasp::Request.new(fasp_provider).post(path)
    else
      Fasp::Request.new(fasp_provider).delete(path)
    end
  end
end
