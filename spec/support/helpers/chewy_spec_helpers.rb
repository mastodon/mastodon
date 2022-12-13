module ChewySpecHelpers
  def with_chewy_disabled(&block)
    with_chewy_settings(enabled: false, &block)
  end
  def with_chewy_settings(new_settings)
    old_settings = Chewy.settings
    merged_settings = old_settings.merge(new_settings)
    Chewy.settings  = merged_settings
    yield
  ensure
    Chewy.settings = old_settings
  end
end

RSpec.configure do |config|
  config.include ChewySpecHelpers, type: :service
  config.around :each, type: :service, disable_chewy: true do |example|
    with_chewy_disabled do 
      example.run
    end
  end
end
