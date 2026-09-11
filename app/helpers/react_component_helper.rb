# frozen_string_literal: true

module ReactComponentHelper
  def react_component(name, props = {}, &block)
    data = { component: name.to_s.camelcase, props: }
    if block_given?
      tag.div data:, &block
    else
      tag.div nil, data:
    end
  end

  def react_admin_component(name, props = {})
    data = { 'admin-component': name.to_s.camelcase, props: }
    tag.div nil, data:
  end
end
