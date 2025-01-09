# frozen_string_literal: true

Fabricator(:import) do
  account
  type :following
  data { attachment_fixture('imports.txt') }
end
