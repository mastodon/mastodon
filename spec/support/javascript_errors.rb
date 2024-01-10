# frozen_string_literal: true

RSpec.configure do |config|
  config.after(:each, type: :system) do
    errors = page.driver.browser.logs.get(:browser)
    if errors.present?
      aggregate_failures 'javascript errrors' do
        errors.each do |error|
          expect(error.level).to_not eq('SEVERE'), error.message
          next unless error.level == 'WARNING'

          $stderr.warn 'WARN: javascript warning'
          $stderr.warn error.message
        end
      end
    end
  end
end
