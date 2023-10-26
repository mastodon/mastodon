# frozen_string_literal: true

module Settings::ImportsHelper
  def import_types_collection
    {
      constructive: %i(following bookmarks lists),
      destructive: %i(muting blocking domain_blocking),
    }
  end

  def import_type_label(type)
    I18n.t("imports.types.#{type}")
  end

  def import_group_label(group)
    I18n.t("imports.type_groups.#{group.first}")
  end
end
