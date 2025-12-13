# frozen_string_literal: true

module BrowserErrorsHelpers
  def ignore_js_error(error)
    @ignored_js_errors_for_spec << error
  end
end

RSpec.configure do |config|
  config.include BrowserErrorsHelpers, :js, type: :system

  config.before(:each, :js, type: :system) do |example|
    @ignored_js_errors_for_spec = []

    example.metadata[:js_console_messages] ||= []
    Capybara.current_session.driver.with_playwright_page do |page|
      page.on('console', lambda { |msg|
        example.metadata[:js_console_messages] << { type: msg.type, text: msg.text, location: msg.location }
      })
    end
  end

  config.after(:each, :js, type: :system) do |example|
    # Classes of intermittent ignorable errors
    ignored_errors = [
      /Error while trying to use the following icon from the Manifest/, # https://github.com/mastodon/mastodon/pull/30793
      /Manifest: Line: 1, column: 1, Syntax error/, # Similar parsing/interruption issue as above
    ].concat(@ignored_js_errors_for_spec)

    errors = example.metadata[:js_console_messages].reject do |msg|
      ignored_errors.any? { |pattern| pattern.match(msg[:text]) }
    end

    if errors.present?
      aggregate_failures 'browser errrors' do
        errors.each do |error|
          expect(error[:type]).to_not eq('error'), error[:text]
          next unless error[:type] == 'warning'

          warn 'WARN: browser warning'
          warn error[:text]
        end
      end
    end
  end
end
