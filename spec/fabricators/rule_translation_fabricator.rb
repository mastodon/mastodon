# frozen_string_literal: true

Fabricator(:rule_translation) do
  text     'MyText'
  hint     'MyText'
  language 'en'
  rule     { Fabricate.build(:rule) }
end
