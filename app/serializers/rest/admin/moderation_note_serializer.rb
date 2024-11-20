# frozen_string_literal: true

class REST::Admin::ModerationNoteSerializer < ActiveModel::Serializer
  include RoutingHelper

  attributes :id, :content, :created_at, :updated_at, :target
  belongs_to :account, serializer: REST::Admin::AccountMinimalSerializer

  def id
    object.id.to_s
  end

  def content
    object.content.strip
  end

  def target
    case object
    when ReportNote
      { type: 'Report', id: object.report_id.to_s, url: api_v1_admin_report_url(object.report) }
    when AccountModerationNote
      { type: 'Account', id: object.target_account_id.to_s, url: api_v1_admin_account_url(object.target_account) }
    end
  end
end
