require 'spec_helper'
require 'hashie'

describe Hashie::Extensions do
  describe 'autloads constants' do
    it { is_expected.to be_const_defined(:MethodAccess) }
    it { is_expected.to be_const_defined(:Coercion) }
    it { is_expected.to be_const_defined(:DeepMerge) }
    it { is_expected.to be_const_defined(:IgnoreUndeclared) }
    it { is_expected.to be_const_defined(:IndifferentAccess) }
    it { is_expected.to be_const_defined(:MergeInitializer) }
    it { is_expected.to be_const_defined(:MethodAccess) }
    it { is_expected.to be_const_defined(:MethodQuery) }
    it { is_expected.to be_const_defined(:MethodReader) }
    it { is_expected.to be_const_defined(:MethodWriter) }
    it { is_expected.to be_const_defined(:StringifyKeys) }
    it { is_expected.to be_const_defined(:SymbolizeKeys) }
    it { is_expected.to be_const_defined(:DeepFetch) }
    it { is_expected.to be_const_defined(:DeepFind) }
    it { is_expected.to be_const_defined(:PrettyInspect) }
    it { is_expected.to be_const_defined(:KeyConversion) }
    it { is_expected.to be_const_defined(:MethodAccessWithOverride) }
  end
end
