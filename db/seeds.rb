# frozen_string_literal: true

Dir[Rails.root.join('db', 'seeds', '*.rb')].sort.each do |seed|
  load seed
end
