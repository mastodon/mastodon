# frozen_string_literal: true

module AccountsHelper
  def pagination_options
    {
      previous_label: safe_join([fa_icon('chevron-left'), t('pagination.prev')], ' '),
      next_label: safe_join([t('pagination.next'), fa_icon('chevron-right')], ' '),
      inner_window: 1,
      outer_window: 0,
    }
  end
end
