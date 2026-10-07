# frozen_string_literal: true

RSS::Builder.build do |doc|
  doc.title(display_name(@account))
  doc.description(I18n.t('rss.descriptions.account', acct: @account.local_username_and_domain))
  doc.link(params[:tag].present? ? short_account_tag_url(@account, params[:tag]) : short_account_url(@account))
  doc.image(full_asset_url(@account.avatar.url(:original)), display_name(@account), params[:tag].present? ? short_account_tag_url(@account, params[:tag]) : short_account_url(@account))
  doc.last_build_date(@statuses.first.created_at) if @statuses.any?
  doc.icon(full_asset_url(@account.avatar.url(:original)))
  doc.generator("Mastodon v#{Mastodon::Version}")

  @statuses.each do |status|
    render 'shared/rss_item', doc: doc, status: status
  end
end
