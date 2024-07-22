# frozen_string_literal: true

RSpec.configure do |config|
  config.after(:each, :js, type: :system) do
    # Classes of intermittent ignorable errors
    ignored_errors = [
      /Error while trying to use the following icon from the Manifest/, # https://github.com/mastodon/mastodon/pull/30793
      /Manifest: Line: 1, column: 1, Syntax error/, # Similar parsing/interruption issue as above
    ]
    errors = page.driver.browser.logs.get(:browser).reject do |error|
      ignored_errors.any? { |pattern| pattern.match(error.message) }
    end

    if errors.present?
      aggregate_failures 'javascript errrors' do
        errors.each do |error|
          expect(error.level).to_not eq('SEVERE'), error.message
          next unless error.level == 'WARNING'

          warn 'WARN: javascript warning'
          warn error.message
        end
      end
    end
  end
end
