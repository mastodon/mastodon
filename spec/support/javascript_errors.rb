# frozen_string_literal: true

RSpec.configure do |config|
  config.after(:each, :js, type: :system) do
    ignored_errors = [
      /icon from the Manifest/,
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
