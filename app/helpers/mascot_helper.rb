# frozen_string_literal: true

module MascotHelper
  def mascot_url
    full_asset_url(instance_presenter.mascot&.file&.url || asset_pack_path('media/images/elephant_ui_plane.svg'))
  end

  private

  def instance_presenter
    @instance_presenter ||= InstancePresenter.new
  end
end
