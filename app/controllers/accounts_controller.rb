# frozen_string_literal: true

class AccountsController < ApplicationController
  include AccountControllerConcern

  def show
    respond_to do |format|
      format.html do
        @statuses = @account.statuses.permitted_for(@account, current_account).order(id: :desc).paginate_by_max_id(20, params[:max_id], params[:since_id])
        @statuses = cache_collection(@statuses, Status)
      end

      format.atom do
        @entries = @account.stream_entries.order(id: :desc).where(hidden: false).with_includes.paginate_by_max_id(20, params[:max_id], params[:since_id])
        render xml: AtomSerializer.render(AtomSerializer.new.feed(@account, @entries.to_a))
      end

      format.activitystreams2
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:username])
  end
end
