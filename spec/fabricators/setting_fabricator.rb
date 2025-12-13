# frozen_string_literal: true

Fabricator(:setting) do
  var { sequence(:var) { |n| "var_#{n}" } }
end
