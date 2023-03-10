# frozen_string_literal: true

module ReactHelper
  def react_component(name, props = {}, &block)
    data = { component: name.to_s.camelcase, props: Oj.dump(props) }
    if block.nil?
      content_tag(:div, nil, data: data)
    else
      content_tag(:div, data: data, &block)
    end
  end

  def react_admin_component(name, props = {})
    data = { 'admin-component': name.to_s.camelcase, props: Oj.dump({ locale: I18n.locale }.merge(props)) }
    content_tag(:div, nil, data: data)
  end
end
