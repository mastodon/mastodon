# frozen_string_literal: true

class Context < ActiveModelSerializers::Model
  attributes :ancestors, :descendants

  class Gap < ActiveModelSerializers::Model
    attributes :id
  end

  class DepthGap < Gap; end
  class LimitGap < Gap; end
  class FilterGap < Gap; end
end
