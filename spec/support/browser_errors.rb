# frozen_string_literal: true

module BrowserErrorsHelpers
  def ignore_js_error(error)
    @ignored_js_errors_for_spec << error
  end
end

RSpec.configure do |config|
  config.include BrowserErrorsHelpers, :js, type: :system

  config.before(:each, :js, type: :system) do
    @ignored_js_errors_for_spec = []
  end

  config.after(:each, :js, type: :system) do
    # Classes of intermittent ignorable errors
    ignored_errors = [
      /Error while trying to use the following icon from the Manifest/, # https://github.com/mastodon/mastodon/pull/30793
      /Manifest: Line: 1, column: 1, Syntax error/, # Similar parsing/interruption issue as above
    ].concat(@ignored_js_errors_for_spec)

    errors = page.driver.browser.logs.get(:browser).reject do |error|
      ignored_errors.any? { |pattern| pattern.match(error.message) }
    end

    if errors.present?
      aggregate_failures 'browser errrors' do
        errors.each do |error|
          expect(error.level).to_not eq('SEVERE'), error.message
          next unless error.level == 'WARNING'

          warn 'WARN: browser warning'
          warn error.message
        end
      end
    end
  end
end
