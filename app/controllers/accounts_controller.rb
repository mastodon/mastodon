# frozen_string_literal: true

class AccountsController < ApplicationController
  include AccountControllerConcern
  include SignatureVerification

  def show
    respond_to do |format|
      format.html do
        @statuses = @account.statuses.permitted_for(@account, current_account).paginate_by_max_id(20, params[:max_id], params[:since_id])
        @statuses = cache_collection(@statuses, Status)
      end

      format.atom do
        @entries = @account.stream_entries.where(hidden: false).with_includes.paginate_by_max_id(20, params[:max_id], params[:since_id])
        render xml: OStatus::AtomSerializer.render(OStatus::AtomSerializer.new.feed(@account, @entries.to_a))
      end

      format.json do
        render json: @account, serializer: ActivityPub::ActorSerializer, adapter: ActivityPub::Adapter
      end
    end
  end

  private

  def set_account
    @account = Account.find_local!(params[:username])
  end
end
