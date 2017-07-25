# frozen_string_literal: true

class ServiceWorkerController < ApplicationController
  def show
    f = Rails.root.join('public/assets/sw.js')
    if f.readable?
      send_data f.read, { :type => 'application/javascript; charset=UTF-8' }
    else
      raise ActiveRecord::RecordNotFound
    end
  end
end
