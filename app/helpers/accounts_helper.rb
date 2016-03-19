module AccountsHelper
  def pagination_options
    { previous_label: "#{fa_icon('chevron-left')} Prev".html_safe, next_label: "Next #{fa_icon('chevron-right')}".html_safe, inner_window: 2 }
  end
end
