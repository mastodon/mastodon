# frozen_string_literal: true

class AboutController < ApplicationController
  layout 'public'

  before_action :require_open_federation!, only: [:show, :more]
  before_action :check_blocklist_enabled, only: [:blocks]
  before_action :require_user!, only: [:blocks], if: :blocklist_account_required?
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
    @blocks = DomainBlock.all
  end

  private

  def require_open_federation!
    not_found if whitelist_mode?
  end

  def check_blocklist_enabled
    nil #TODO
  end

  def blocklist_account_required?
    false #TODO
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

  def new_user
    User.new.tap do |user|
      user.build_account
      user.build_invite_request
    end
  end

  helper_method :new_user

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
