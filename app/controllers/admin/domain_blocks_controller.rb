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

module Admin
  class DomainBlocksController < BaseController
    before_action :set_domain_block, only: [:show, :destroy]

    def index
      @domain_blocks = DomainBlock.page(params[:page])
    end

    def new
      @domain_block = DomainBlock.new
    end

    def create
      @domain_block = DomainBlock.new(resource_params)

      if @domain_block.save
        DomainBlockWorker.perform_async(@domain_block.id)
        redirect_to admin_domain_blocks_path, notice: I18n.t('admin.domain_blocks.created_msg')
      else
        render :new
      end
    end

    def show; end

    def destroy
      UnblockDomainService.new.call(@domain_block, retroactive_unblock?)
      redirect_to admin_domain_blocks_path, notice: I18n.t('admin.domain_blocks.destroyed_msg')
    end

    private

    def set_domain_block
      @domain_block = DomainBlock.find(params[:id])
    end

    def resource_params
      params.require(:domain_block).permit(:domain, :severity, :reject_media, :retroactive)
    end

    def retroactive_unblock?
      ActiveRecord::Type.lookup(:boolean).cast(resource_params[:retroactive])
    end
  end
end
