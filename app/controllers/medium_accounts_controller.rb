# frozen_string_literal: true

class MediumAccountsController < ApplicationController
  include AccountControllerConcern

  def index
    @statuses = @account.statuses.permitted_for(@account, current_account).order('id desc').paginate_by_max_id(20, params[:max_id], params[:since_id])
    status_ids = @statuses.joins(:media_attachments).distinct(:id).ids
    @statuses = @statuses.where(id: status_ids)
    @statuses = cache_collection(@statuses, Status)
  end
end
