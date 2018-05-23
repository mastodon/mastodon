RSpec::Matchers.define :have_column do |column_name|
  chain :with_default do |default|
    @default = default
  end

  match do |columns|
    column = columns.detect{|column| column.name == column_name }
    column && column.default.to_s == @default.to_s
  end

  failure_message_method =
    if RSpec::Version::STRING.to_i >= 3
      :failure_message
    else
      :failure_message_for_should
    end

  send(failure_message_method) do |columns|
    "expected to find '#{column_name}', " +
      "default '#{@default}' " +
      "in #{columns.map { |column| [column.name, column.default] }}"
  end
end
