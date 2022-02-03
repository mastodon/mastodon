# frozen_string_literal: true

class REST::Admin::IpSerializer < ActiveModel::Serializer
  attributes :ip, :used_at
end
