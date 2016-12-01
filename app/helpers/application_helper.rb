# frozen_string_literal: true

module ApplicationHelper
  def active_nav_class(path)
    current_page?(path) ? 'active' : ''
  end

  def id_paginate(path, per_page, collection)
  	# todo
  end
end
