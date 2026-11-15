# frozen_string_literal: true

RSS::Builder.build do |doc|
  doc.title('Explore: Trending posts')

  doc.last_build_date(@statuses.first.created_at) if @statuses.any?
  doc.generator("Mastodon v#{Mastodon::Version}")

  @statuses.each do |status|
    render 'shared/rss_item', doc: doc, status: status
  end
end
