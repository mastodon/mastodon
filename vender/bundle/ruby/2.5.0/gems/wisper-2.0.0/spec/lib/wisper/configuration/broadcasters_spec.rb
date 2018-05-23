module Wisper
  describe Configuration::Broadcasters do
    describe 'broadcasters' do
      describe '#to_h' do
        it 'returns a Hash' do
          expect(subject.to_h).to be_instance_of(Hash)
        end
      end
    end
  end
end
