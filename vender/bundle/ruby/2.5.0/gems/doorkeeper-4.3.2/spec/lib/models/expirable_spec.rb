require 'spec_helper'
require 'active_support/time'
require 'doorkeeper/models/concerns/expirable'

describe 'Expirable' do
  subject do
    Class.new do
      include Doorkeeper::Models::Expirable
    end.new
  end

  before do
    allow(subject).to receive(:created_at).and_return(1.minute.ago)
  end

  describe :expired? do
    it 'is not expired if time has not passed' do
      allow(subject).to receive(:expires_in).and_return(2.minutes)
      expect(subject).not_to be_expired
    end

    it 'is expired if time has passed' do
      allow(subject).to receive(:expires_in).and_return(10.seconds)
      expect(subject).to be_expired
    end

    it 'is not expired if expires_in is not set' do
      allow(subject).to receive(:expires_in).and_return(nil)
      expect(subject).not_to be_expired
    end
  end

  describe :expires_in_seconds do
    it 'should return the amount of time remaining until the token is expired' do
      allow(subject).to receive(:expires_in).and_return(2.minutes)
      expect(subject.expires_in_seconds).to eq(60)
    end

    it 'should return 0 when expired' do
      allow(subject).to receive(:expires_in).and_return(30.seconds)
      expect(subject.expires_in_seconds).to eq(0)
    end

    it 'should return nil when expires_in is nil' do
      allow(subject).to receive(:expires_in).and_return(nil)
      expect(subject.expires_in_seconds).to be_nil
    end

  end
end
