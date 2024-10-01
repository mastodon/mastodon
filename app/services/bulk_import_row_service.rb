# frozen_string_literal: true

class BulkImportRowService
  def call(row)
    @account = row.bulk_import.account
    @data    = row.data
    @type    = row.bulk_import.type.to_sym

    case @type
    when :following, :blocking, :muting, :lists
      target_acct     = @data['acct']
      target_domain   = domain(target_acct)
      @target_account = stoplight_wrapper(target_domain).run { ResolveAccountService.new.call(target_acct, { check_delivery_availability: true }) }
      return false if @target_account.nil?
    when :bookmarks
      target_uri      = @data['uri']
      target_domain   = Addressable::URI.parse(target_uri).normalized_host
      @target_status = ActivityPub::TagManager.instance.uri_to_resource(target_uri, Status)
      return false if @target_status.nil? && ActivityPub::TagManager.instance.local_uri?(target_uri)

      @target_status ||= stoplight_wrapper(target_domain).run { ActivityPub::FetchRemoteStatusService.new.call(target_uri) }
      return false if @target_status.nil?
    end

    case @type
    when :following
      FollowService.new.call(@account, @target_account, reblogs: @data['show_reblogs'], notify: @data['notify'], languages: @data['languages'])
    when :blocking
      BlockService.new.call(@account, @target_account)
    when :muting
      MuteService.new.call(@account, @target_account, notifications: @data['hide_notifications'])
    when :bookmarks
      return false unless StatusPolicy.new(@account, @target_status).show?

      @account.bookmarks.find_or_create_by!(status: @target_status)
    when :lists
      list = @account.owned_lists.find_or_create_by!(title: @data['list_name'])

      FollowService.new.call(@account, @target_account) unless @account.id == @target_account.id

      list.accounts << @target_account
    end

    true
  rescue ActiveRecord::RecordNotFound
    false
  end

  def domain(uri)
    domain = uri.is_a?(Account) ? uri.domain : uri.split('@')[1]
    TagManager.instance.local_domain?(domain) ? nil : TagManager.instance.normalize_domain(domain)
  end

  def stoplight_wrapper(domain)
    if domain.present?
      Stoplight("source:#{domain}")
        .with_fallback { nil }
        .with_threshold(1)
        .with_cool_off_time(5.minutes.seconds)
        .with_error_handler { |error, handle| error.is_a?(HTTP::Error) || error.is_a?(OpenSSL::SSL::SSLError) ? handle.call(error) : raise(error) }
    else
      Stoplight('domain-blank')
    end
  end
end
