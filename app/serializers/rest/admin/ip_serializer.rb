# frozen_string_literal: true

class REST::Admin::IpSerializer < REST::BaseSerializer
  attributes :ip, :used_at
end
