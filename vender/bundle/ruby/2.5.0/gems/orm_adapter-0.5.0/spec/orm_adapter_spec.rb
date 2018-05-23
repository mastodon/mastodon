require 'spec_helper'

describe OrmAdapter do
  subject { OrmAdapter }
  
  describe "when a new adapter is created (by inheriting form OrmAdapter::Base)" do
    let!(:adapter) { Class.new(OrmAdapter::Base) }
    
    its(:adapters) { should include(adapter) }
    
    after { OrmAdapter.adapters.delete(adapter) }
  end
end
