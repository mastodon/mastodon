# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'admin/trends/links/_preview_card.html.haml' do
  it 'correctly escapes user supplied url values' do
    form = instance_double(ActionView::Helpers::FormHelper, check_box: nil)
    trend = PreviewCardTrend.new(allowed: false)
    preview_card = Fabricate.build(
      :preview_card,
      url: 'https://host.example/path?query=<script>',
      trend: trend,
      title: 'Fun'
    )

    render partial: 'admin/trends/links/preview_card', locals: { preview_card: preview_card, f: form }

    expect(rendered).to include('<a href="https://host.example/path?query=&lt;script&gt;">Fun</a>')
  end
end
