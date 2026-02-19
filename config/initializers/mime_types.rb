# frozen_string_literal: true

Mime::Type.register 'application/json', :json, %w(text/x-json application/jsonrequest application/jrd+json application/activity+json application/ld+json)
Mime::Type.register 'text/xml',         :xml,  %w(application/xml application/atom+xml application/xrd+xml)
