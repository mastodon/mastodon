# frozen_string_literal: true

module ReactHelper
  def react_component(name, props = {}, &block)
    if block.nil?
      content_tag(:div, nil, data: { component: name.to_s.camelcase, props: Oj.dump(props) })
    else
      content_tag(:div, data: { component: name.to_s.camelcase, props: Oj.dump(props) }, &block)
    end
  end

  def react_admin_component(name, props = {})
    content_tag(:div, nil, data: { 'admin-component': name.to_s.camelcase, props: Oj.dump({ locale: I18n.locale }.merge(props)) })
  end
end
