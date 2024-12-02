# frozen_string_literal: true

require 'csv'

class Settings::ImportsController < Settings::BaseController
  before_action :set_bulk_import, only: [:show, :confirm, :destroy]
  before_action :set_recent_imports, only: [:index]

  TYPE_TO_FILENAME_MAP = {
    following: 'following_accounts_failures.csv',
    blocking: 'blocked_accounts_failures.csv',
    muting: 'muted_accounts_failures.csv',
    domain_blocking: 'blocked_domains_failures.csv',
    bookmarks: 'bookmarks_failures.csv',
    lists: 'lists_failures.csv',
  }.freeze

  TYPE_TO_HEADERS_MAP = {
    following: ['Account address', 'Show boosts', 'Notify on new posts', 'Languages'],
    blocking: false,
    muting: ['Account address', 'Hide notifications'],
    domain_blocking: false,
    bookmarks: false,
    lists: false,
  }.freeze

  RECENT_IMPORTS_LIMIT = 10

  def index
    @import = Form::Import.new(current_account: current_account)
  end

  def show; end

  def failures
    @bulk_import = current_account.bulk_imports.state_finished.find(params[:id])

    respond_to do |format|
      format.csv do
        filename = TYPE_TO_FILENAME_MAP[@bulk_import.type.to_sym]
        headers = TYPE_TO_HEADERS_MAP[@bulk_import.type.to_sym]

        export_data = CSV.generate(headers: headers, write_headers: true) do |csv|
          @bulk_import.rows.find_each do |row|
            case @bulk_import.type.to_sym
            when :following
              csv << [row.data['acct'], row.data.fetch('show_reblogs', true), row.data.fetch('notify', false), row.data['languages']&.join(', ')]
            when :blocking
              csv << [row.data['acct']]
            when :muting
              csv << [row.data['acct'], row.data.fetch('hide_notifications', true)]
            when :domain_blocking
              csv << [row.data['domain']]
            when :bookmarks
              csv << [row.data['uri']]
            when :lists
              csv << [row.data['list_name'], row.data['acct']]
            end
          end
        end

        send_data export_data, filename: filename
      end
    end
  end

  def confirm
    @bulk_import.update!(state: :scheduled)
    BulkImportWorker.perform_async(@bulk_import.id)
    redirect_to settings_imports_path, notice: I18n.t('imports.success')
  end

  def create
    @import = Form::Import.new(import_params.merge(current_account: current_account))

    if @import.save
      redirect_to settings_import_path(@import.bulk_import.id)
    else
      # We need to set recent imports as we are displaying the index again
      set_recent_imports
      render :index
    end
  end

  def destroy
    @bulk_import.destroy!
    redirect_to settings_imports_path
  end

  private

  def import_params
    params.require(:form_import).permit(:data, :type, :mode)
  end

  def set_bulk_import
    @bulk_import = current_account.bulk_imports.state_unconfirmed.find(params[:id])
  end

  def set_recent_imports
    @recent_imports = current_account.bulk_imports.reorder(id: :desc).limit(RECENT_IMPORTS_LIMIT)
  end
end
