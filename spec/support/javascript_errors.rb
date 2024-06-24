# frozen_string_literal: true

RSpec.configure do |config|
  config.after(:each, :js, type: :system) do
    performance_logs = page.driver.browser.logs.get(:performance).map(&:message)
    errors = page.driver.browser.logs.get(:browser)

    # Save performance logs to capybara directory for further inspection
    if performance_logs.present? && errors.present? && errors.any? { |error| error.level == 'SEVERE' }
      path = File.join(Capybara.save_path, "performance-log-#{SecureRandom.hex(10)}.json")

      warn "WARN: saving performance logs to #{path}"

      File.write(path, "[#{performance_logs.join(',')}]")
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
