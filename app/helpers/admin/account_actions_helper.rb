# frozen_string_literal: true

module Admin::AccountActionsHelper
  def account_action_type_label(type)
    safe_join(
      [
        I18n.t("simple_form.labels.admin_account_action.types.#{type}"),
        content_tag(:span, I18n.t("simple_form.hints.admin_account_action.types.#{type}"), class: 'hint'),
      ]
    )
  end

  def label_and_categories_collection(warning_presets)
    warning_presets.map { |p| [[p.title.presence, truncate(p.text)].compact.join(' - '), p.id, { data: { type: p.action_category } }] }
  end

  def combined_types_collection
    Admin::AccountAction::TYPES + Admin::ModerationAction::TYPES
  end

  def collection
    if params[:report_id].present?
      combined_types_collection
    else
      Admin::AccountAction::TYPES
    end
  end

  def button_collection
    key_map =
      {
        'delete' => 'delete_statuses',
        'mark_as_sensitive' => 'mark_statuses_as_sensitive',
        'sensitive' => 'sensitive',
        'silence' => 'silence',
        'suspend' => 'suspend',
        'disable' => 'disable',
      }

    types = if params[:report_id].present?
              combined_types_collection
            else
              Admin::AccountAction::TYPES
            end
    types.map { |type| [type, type, { data: { button_label: I18n.t("admin.account_actions.types.#{type}"), strike_card: I18n.t("user_mailer.warning.explanation.#{key_map[type]}", instance: Rails.configuration.x.local_domain) } }] }
  end
end
