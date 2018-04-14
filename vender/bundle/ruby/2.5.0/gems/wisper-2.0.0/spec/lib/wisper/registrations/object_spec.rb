describe Wisper::ObjectRegistration do

  describe 'broadcaster' do
    it 'defaults to SendBroadcaster' do
      subject = Wisper::ObjectRegistration.new(double('listener'), {})
      expect(subject.broadcaster).to be_instance_of(Wisper::Broadcasters::SendBroadcaster)
    end

    it 'default is lazily evaluated' do
      expect(Wisper::Broadcasters::SendBroadcaster).to_not receive :new
      Wisper::ObjectRegistration.new(double('listener'), broadcaster: double('DifferentBroadcaster').as_null_object)
    end
  end
end
