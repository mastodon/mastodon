# frozen_string_literal: true

Fabricator(:tagging) do
  tag
  taggable { Fabricate :status }
end
