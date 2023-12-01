# frozen_string_literal: true

class MailSubscriptionsController < ApplicationController
  layout 'auth'

  skip_before_action :require_functional!

  before_action :set_body_classes
  before_action :set_user
  before_action :set_type

  protect_from_forgery with: :null_session

  def show; end

  def create
    @user.settings[email_type_from_param] = false
    @user.save!
  end

  private

  def set_user
    @user = GlobalID::Locator.locate_signed(params[:token], for: 'unsubscribe')
    not_found unless @user
  end

  def set_body_classes
    @body_classes = 'lighter'
  end

  def set_type
    @type = email_type_from_param
  end

  def email_type_from_param
    case params[:type]
    when 'follow', 'reblog', 'favourite', 'mention', 'follow_request'
      "notification_emails.#{params[:type]}"
    else
      not_found
    end
  end
end
