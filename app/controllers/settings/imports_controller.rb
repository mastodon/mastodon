# frozen_string_literal: true
#
# Mastodon, a GNU Social-compatible microblogging server
# Copyright (C) 2016-2017 Eugen Rochko & al (see the AUTHORS file)
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU Affero General Public License for more details.
#
# You should have received a copy of the GNU Affero General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

class Settings::ImportsController < ApplicationController
  layout 'admin'

  before_action :authenticate_user!
  before_action :set_account

  def show
    @import = Import.new
  end

  def create
    @import = Import.new(import_params)
    @import.account = @account

    if @import.save
      ImportWorker.perform_async(@import.id)
      redirect_to settings_import_path, notice: I18n.t('imports.success')
    else
      render :show
    end
  end

  private

  def set_account
    @account = current_user.account
  end

  def import_params
    params.require(:import).permit(:data, :type)
  end
end
