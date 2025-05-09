# frozen_string_literal: true

class TermsOfServiceInterstitialController < ApplicationController
  vary_by 'Accept-Language'

  def show
    @terms_of_service = TermsOfService.published.first

    render 'terms_of_service_interstitial/show', layout: 'auth'
  end
end
