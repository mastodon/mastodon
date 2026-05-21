# frozen_string_literal: true

# == Schema Information
#
# Table name: tagged_objects
#
#  id          :bigint(8)        not null, primary key
#  ap_type     :string           not null
#  object_type :string
#  uri         :string
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  object_id   :bigint(8)
#  status_id   :bigint(8)        not null
#
class TaggedObject < ApplicationRecord
  belongs_to :status, inverse_of: :tagged_objects
  belongs_to :object, polymorphic: true, optional: true
end
