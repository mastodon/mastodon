# frozen_string_literal: true

module Admin::UsernameBlocksHelper
  def username_block_link(username_block)
    string = tag.samp link_to(username_block.username, edit_admin_username_block_path(username_block))

    if username_block.exact?
      t('admin.username_blocks.matches_exactly_html', string:)
    else
      t('admin.username_blocks.contains_html', string:)
    end
  end
end
