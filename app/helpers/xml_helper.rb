# frozen_string_literal: true

module XmlHelper
  def namespaced_xpath(xpath_str, namespaces = {})
    xpath_str.gsub(/([a-z]+):([a-z\-_]+)/i) do |match|
      namespace, local_name = match.split(':')
      uri                   = namespaces[namespace.to_sym]

      "*[local-name() = \"#{local_name}\" and namespace-uri() = \"#{uri}\"]"
    end
  end
end
