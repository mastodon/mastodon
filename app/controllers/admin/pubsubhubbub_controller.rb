# frozen_string_literal: true

class Admin::PubsubhubbubController < ApplicationController
  before_action :require_admin!

  layout 'admin'

  def index
    @subscriptions = Subscription.order('id desc').includes(:account).paginate(page: params[:page], per_page: 40)
  end
end
