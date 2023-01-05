# frozen_string_literal: true

class Settings::ProfilesController < Settings::BaseController
  before_action :set_account

  def show
    @mastodon_builder_url = 'https://wallet.hello.coop/mastodon'
    if ENV['HELLO_MASTODON_BUILDER_URL']
      @mastodon_builder_url = ENV['HELLO_MASTODON_BUILDER_URL']
    end

    parsed_url = URI.parse(@mastodon_builder_url)
    query = parsed_url.query ? CGI.parse(parsed_url.query) : {}
    query['server'] = [ENV['LOCAL_DOMAIN']]
    parsed_url.query = URI.encode_www_form(query)
    @mastodon_builder_url = parsed_url.to_s

    @account.build_fields
  end

  def update
    if UpdateAccountService.new.call(@account, account_params)
      ActivityPub::UpdateDistributionWorker.perform_async(@account.id)
      redirect_to settings_profile_path, notice: I18n.t('generic.changes_saved_msg')
    else
      @account.build_fields
      render :show
    end
  end

  private

  def account_params
    params.require(:account).permit(:display_name, :note, :avatar, :header, :locked, :bot, :discoverable, :hide_collections, fields_attributes: [:name, :value])
  end

  def set_account
    @account = current_account
  end
end
