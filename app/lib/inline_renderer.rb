# frozen_string_literal: true

class InlineRenderer
  def self.render(status, current_account, template)
    Rabl::Renderer.new(
      template,
      status,
      view_path: 'app/views',
      format: :json,
      scope: InlineRablScope.new(current_account)
    ).render
  end
end
