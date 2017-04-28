# frozen_string_literal: true

class HomeController < ApplicationController
  protect_from_forgery except: :piwik
  skip_before_action :store_current_location, only: :piwik
  # rubocop sees that as a hash ?!
  before_action :authenticate_user!, :except => %i(piwik) # rubocop:disable Style/HashSyntax

  def index
    @body_classes           = 'app-body'
    @token                  = find_or_create_access_token.token
    @web_settings           = Web::Setting.find_by(user: current_user)&.data || {}
    @admin                  = Account.find_local(Setting.site_contact_username)
    @streaming_api_base_url = Rails.configuration.x.streaming_api_base_url
  end

  def piwik
    piwik_user_id =  user_signed_in? ? current_user.id.to_s : ''
    render js: "<!-- Piwik -->
  var _paq = _paq || [];
  /* tracker methods like 'setCustomDimension' should be called before 'trackPageView' */
  _paq.push(['setDocumentTitle', document.domain + '/' + document.title]);
  _paq.push(['setCookieDomain', '*." + ENV['LOCAL_DOMAIN'] + "']);
  _paq.push(['setDomains', ['*." + ENV['LOCAL_DOMAIN'] + "']]);
  _paq.push(['trackPageView']);
  _paq.push(['enableLinkTracking']);
  (function() {
    var u='//" + ENV['PIWIK_DOMAIN'] + "/';
    _paq.push(['setTrackerUrl', u+'piwik.php']);
    _paq.push(['setSiteId', '" + ENV['PIWIK_SITEID'] + "']);
    _paq.push(['setUserId', '" + piwik_user_id + "']);
    _paq.push(['trackVisibleContentImpressions']);
    var d=document, g=d.createElement('script'), s=d.getElementsByTagName('script')[0];
    g.type='text/javascript'; g.async=true; g.defer=true; g.src=u+'piwik.js'; s.parentNode.insertBefore(g,s);
  })();
<!-- End Piwik Code -->"
  end

  private

  def authenticate_user!
    redirect_to(single_user_mode? ? account_path(Account.first) : about_path) unless user_signed_in?
  end

  def find_or_create_access_token
    Doorkeeper::AccessToken.find_or_create_for(
      Doorkeeper::Application.where(superapp: true).first,
      current_user.id,
      Doorkeeper::OAuth::Scopes.from_string('read write follow'),
      Doorkeeper.configuration.access_token_expires_in,
      Doorkeeper.configuration.refresh_token_enabled?
    )
  end
end
