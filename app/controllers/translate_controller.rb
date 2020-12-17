# frozen_string_literal: true

class TranslateController < ApplicationController
  before_action :authenticate_user!

  def create

    if !user_signed_in?
      render json: {
        'text' => I18n.t('errors.login_to_translate'),
      }
      return
    end

    if !ENV['TRANSLATION_SERVER_HOST']
      render json: {
        'text' => 'TRANSLATION_SERVER_HOST not found in ENV',
      }
      return
    end

    endpoint = ENV['TRANSLATION_SERVER_HOST']

    text = params[:data][:text]
    to = params[:data][:to]

    if ENV['TRANSLATION_SERVER_TYPE'] == 'rsshub'

      to = 'zh-CN' if to == 'zh-cn'
      to = 'zh-TW' if to == 'zh-tw'
      sha = Digest::SHA1.hexdigest(text)
      route = "/google/translate/#{to}/#{sha}/1/auto/#{ENV['TRANSLATION_SERVER_GOOGLE_DOMAIN'] || 'com.hk'}/.json"
      text = URI::encode(text)

      resp = Faraday.get("#{endpoint}#{route}", { :text => text })
      res = ActiveSupport::JSON.decode(resp.body)

      respond = {
        'text' => res['items'][0]['description'],
      }

      render json: respond

    else

      resp = Faraday.post(endpoint, text: text, to: to)
      render json: ActiveSupport::JSON.decode(resp.body)

    end

  end
end
