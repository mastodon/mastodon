# frozen_string_literal: true

module AccountsHelper
  def pagination_options
    {
      previous_label: safe_join([fa_icon('chevron-left'), 'Prev'], ' '),
      next_label: safe_join(['Next', fa_icon('chevron-right')], ' '),
      inner_window: 1,
      outer_window: 0,
    }
  end
end
