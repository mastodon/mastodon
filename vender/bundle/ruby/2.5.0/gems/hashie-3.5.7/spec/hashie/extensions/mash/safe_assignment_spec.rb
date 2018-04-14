require 'spec_helper'

describe Hashie::Extensions::Mash::SafeAssignment do
  class MashWithSafeAssignment < Hashie::Mash
    include Hashie::Extensions::Mash::SafeAssignment

    private

    def my_own_private
      :hello!
    end
  end

  context 'when included in Mash' do
    subject { MashWithSafeAssignment.new }

    context 'when not attempting to override a method' do
      it 'assigns just fine' do
        expect do
          subject.blabla = 'Test'
          subject.blabla = 'Test'
        end.to_not raise_error
      end
    end

    context 'when attempting to override a method' do
      it 'raises an error' do
        expect { subject.zip = 'Test' }.to raise_error(ArgumentError)
      end
    end

    context 'when attempting to override a private method' do
      it 'raises an error' do
        expect { subject.my_own_private = 'Test' }.to raise_error(ArgumentError)
      end
    end

    context 'when attempting to initialize with predefined method' do
      it 'raises an error' do
        expect { MashWithSafeAssignment.new(zip: true) }.to raise_error(ArgumentError)
      end
    end

    context 'when setting as a hash key' do
      it 'still raises if conflicts with a method' do
        expect { subject[:zip] = 'Test' }.to raise_error(ArgumentError)
      end
    end
  end
end
