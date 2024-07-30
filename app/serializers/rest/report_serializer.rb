# frozen_string_literal: true

class REST::ReportSerializer < REST::BaseReportSerializer
  has_one :target_account, serializer: REST::AccountSerializer
end
