object false

node(:title) {Setting.site_title}

node(:max_chars) {500}

node(:links) do
  {
    t('about.learn_more') => url_for(about_more_url),
    t('about.terms') => url_for(terms_url),
    t('about.source_code') => "https://github.com/tootsuite/mastodon",
    t('about.other_instances') => "https://github.com/tootsuite/mastodon/blob/master/docs/Using-Mastodon/List-of-Mastodon-instances.md",
  }
end
