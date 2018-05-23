shared_examples 'an accessible token' do
  describe :accessible? do
    it 'is accessible if token is not expired' do
      allow(subject).to receive(:expired?).and_return(false)
      should be_accessible
    end

    it 'is not accessible if token is expired' do
      allow(subject).to receive(:expired?).and_return(true)
      should_not be_accessible
    end
  end
end

shared_examples 'a revocable token' do
  describe :accessible? do
    before { subject.save! }

    it 'is accessible if token is not revoked' do
      expect(subject).to be_accessible
    end

    it 'is not accessible if token is revoked' do
      subject.revoke
      expect(subject).not_to be_accessible
    end
  end
end

shared_examples 'a unique token' do
  describe :token do
    it 'is generated before validation' do
      expect { subject.valid? }.to change { subject.token }.from(nil)
    end

    it 'is not valid if token exists' do
      token1 = FactoryBot.create factory_name
      token2 = FactoryBot.create factory_name
      token2.token = token1.token
      expect(token2).not_to be_valid
    end

    it 'expects database to throw an error when tokens are the same' do
      token1 = FactoryBot.create factory_name
      token2 = FactoryBot.create factory_name
      token2.token = token1.token
      expect do
        token2.save!(validate: false)
      end.to raise_error(uniqueness_error)
    end
  end
end
