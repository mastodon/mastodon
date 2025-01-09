# frozen_string_literal: true

return unless defined?(Rails::Command::StatsCommand)

[
  %w(AppLibs app/lib),
  %w(Policies app/policies),
  %w(Presenters app/presenters),
  %w(Serializers app/serializers),
  %w(Services app/services),
  %w(Validators app/validators),
  %w(Workers app/workers),
].each do |name, directory|
  Rails::CodeStatistics.register_directory(name.titleize, directory)
end
