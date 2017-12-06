# frozen_string_literal: true

class Settings::ExportsController < Settings::BaseController
  def show
    @export = Export.new(current_account)
  end
end
