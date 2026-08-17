# frozen_string_literal: true

# Create base category for posters
Category.create_with(description: 'Category assigned to all new posters')
  .find_or_create_by(name: 'New Poster')
