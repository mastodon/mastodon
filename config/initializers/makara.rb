Makara::Cookie::DEFAULT_OPTIONS[:same_site] = :lax
Makara::Cookie::DEFAULT_OPTIONS[:secure]    = Rails.env.production? || ENV['LOCAL_HTTPS'] == 'true'
