# frozen_string_literal: true

module Admin
  class AccountModerationNotesController < BaseController
    before_action :set_account_moderation_note, only: [:destroy]

    def create
      authorize AccountModerationNote, :create?

      @account_moderation_note = current_account.account_moderation_notes.new(resource_params)

      if @account_moderation_note.save
        redirect_to admin_account_path(@account_moderation_note.target_account_id), notice: I18n.t('admin.account_moderation_notes.created_msg')
      else
        @account          = @account_moderation_note.target_account
        @moderation_notes = @account.targeted_moderation_notes.latest

        render template: 'admin/accounts/show'
      end
    end

    def destroy
      authorize @account_moderation_note, :destroy?
      @account_moderation_note.destroy!
      redirect_to admin_account_path(@account_moderation_note.target_account_id), notice: I18n.t('admin.account_moderation_notes.destroyed_msg')
    end

    private

    def resource_params
      params.require(:account_moderation_note).permit(
        :content,
        :target_account_id
      )
    end

    def set_account_moderation_note
      @account_moderation_note = AccountModerationNote.find(params[:id])
    end
  end
end
