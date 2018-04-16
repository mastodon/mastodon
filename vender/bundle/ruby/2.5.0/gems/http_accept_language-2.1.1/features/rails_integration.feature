@rails
Feature: Rails Integration

  To use http_accept_language inside a Rails application, just add it to your
  Gemfile and run `bundle install`.

  It is automatically added to your middleware.

  Scenario: Installing
    When I generate a new Rails app
    And I add http_accept_language to my Gemfile
    And I run `rake middleware`
    Then the output should contain "use HttpAcceptLanguage::Middleware"

  Scenario: Using
    Given I have installed http_accept_language
    When I generate the following controller:
    """
    class LanguagesController < ApplicationController

      def index
        languages = http_accept_language.user_preferred_languages
        render :text => "Languages: #{languages.join(' : ')}"
      end

    end
    """
    When I access that action with the HTTP_ACCEPT_LANGUAGE header "en-us,en-gb;q=0.8,en;q=0.6,es-419"
    Then the response should contain "Languages: en-US : es-419 : en-GB : en"
