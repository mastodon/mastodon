# frozen_string_literal: true

class REST::AccountWarningSerializer < REST::BaseAccountWarningSerializer
  has_one :target_account, serializer: REST::AccountSerializer
end
