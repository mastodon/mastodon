# frozen_string_literal: true

# == Schema Information
#
# Table name: fasp_tag_trends
#
#  id               :bigint(8)        not null, primary key
#  allowed          :boolean          default(FALSE), not null
#  language         :string           not null
#  rank             :integer          not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  fasp_provider_id :bigint(8)        not null
#  tag_id           :bigint(8)        not null
#
class Fasp::TagTrend < ApplicationRecord
  belongs_to :tag
  belongs_to :fasp_provider, class_name: 'Fasp::Provider'
end
