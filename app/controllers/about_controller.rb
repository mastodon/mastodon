# frozen_string_literal: true

class AboutController < ApplicationController
  before_action :set_pack
  layout 'public'

  before_action :require_open_federation!, only: [:show, :more, :blocks]
  before_action :check_blocklist_enabled, only: [:blocks]
  before_action :authenticate_user!, only: [:blocks], if: :blocklist_account_required?
  before_action :set_body_classes, only: :show
  before_action :set_instance_presenter
  before_action :set_expires_in, only: [:show, :more, :terms]

  skip_before_action :require_functional!, only: [:more, :terms]

  def show; end

  def more
    flash.now[:notice] = I18n.t('about.instance_actor_flash') if params[:instance_actor]
  end

  def terms; end

  def blocks
    @show_rationale = Setting.show_domain_blocks_rationale == 'all'
    @show_rationale |= Setting.show_domain_blocks_rationale == 'users' && !current_user.nil? && current_user.functional?
    @blocks = DomainBlock.with_user_facing_limitations.order('(CASE severity WHEN 0 THEN 1 WHEN 1 THEN 2 WHEN 2 THEN 0 END), reject_media, domain').to_a
  end

  private

  def require_open_federation!
    not_found if whitelist_mode?
  end

  def check_blocklist_enabled
    not_found if Setting.show_domain_blocks == 'disabled'
  end

  def blocklist_account_required?
    Setting.show_domain_blocks == 'users'
  end

  def block_severity_text(block)
    if block.severity == 'suspend'
      I18n.t('domain_blocks.suspension')
    else
      limitations = []
      limitations << I18n.t('domain_blocks.media_block') if block.reject_media?
      limitations << I18n.t('domain_blocks.silence') if block.severity == 'silence'
      limitations.join(', ')
    end
  end

  helper_method :block_severity_text
  helper_method :public_fetch_mode?

  def new_user
    User.new.tap do |user|
      user.build_account
      user.build_invite_request
    end
  end

  helper_method :new_user

  def set_pack
    use_pack 'public'
  end

  def set_instance_presenter
    @instance_presenter = InstancePresenter.new
  end

  def set_body_classes
    @hide_navbar = true
  end

  def set_expires_in
    expires_in 0, public: true
  end
end
