# frozen_string_literal: true

module TurnstileConcern
  extend ActiveSupport::Concern

  def turnstile_enabled?
    ENV['TURNSTILE_ENABLED'] == 'true'
  end

  def add_csp_for_turnstile
    return unless turnstile_enabled?

    policy = request.content_security_policy
    %w(script_src frame_src style_src connect_src).each do |directive|
      values = policy.send(directive)
      values << 'https://challenges.cloudflare.com' unless values.include?('https:')
      policy.send(directive, *values)
    end
  end

  def check_turnstile
    unless is_success?
      self.resource = resource_class.new sign_up_params
      set_instance_presenter
      flash.now[:alert] = 'Cloudflare Turnstile reports malformed request'
      respond_with_navigational(resource) { render :new }
    end
  end

  private

  def is_success?
    cf_turnstile_response = params["cf-turnstile-response"]
    return false unless cf_turnstile_response.present?
    verify_by_turnstile cf_turnstile_response
  end

  def verify_by_turnstile(cf_turnstile_response)
    conn = Faraday.new(url: 'https://challenges.cloudflare.com')
    res = conn.post '/turnstile/v0/siteverify', {
        secret: ENV['TURNSTILE_SECRET_KEY'],
        response: cf_turnstile_response
    }
    j = JSON.parse(res.body)
    j['success']
  end
end
