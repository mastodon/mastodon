# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_debug_callbacks
#
#  id               :bigint(8)        not null, primary key
#  ip               :string
#  request_body     :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fasp_provider_id :bigint(8)        not null
#
class Fasp::DebugCallback < ApplicationRecord
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'
end
