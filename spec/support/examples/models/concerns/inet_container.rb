# frozen_string_literal: true

RSpec.shared_examples 'InetContainer' do
  describe 'Scopes' do
    describe '.containing' do
      let!(:contained) { Fabricate factory_name, ip: '192.168.0.0/24' }
      let!(:uncontained) { Fabricate factory_name, ip: '10.0.0.0/16' }

      it 'returns records containing the value' do
        expect(described_class.containing('192.168.0.1'))
          .to include(contained)
          .and not_include(uncontained)
      end
    end

    describe '.contained_by' do
      let!(:contained) { Fabricate factory_name, ip: '192.168.0.1' }
      let!(:uncontained) { Fabricate factory_name, ip: '10.0.10.0' }

      it 'returns records contained by the value' do
        expect(described_class.contained_by('192.168.0.0/24'))
          .to include(contained)
          .and not_include(uncontained)
      end
    end

    describe '.overlapping_with' do
      let!(:contained) { Fabricate factory_name, ip: '192.168.0.0/16' }
      let!(:contained_also) { Fabricate factory_name, ip: '192.168.0.1' }
      let!(:uncontained) { Fabricate factory_name, ip: '10.0.10.0' }

      it 'returns records containing or contained by the value' do
        expect(described_class.overlapping_with('192.168.0.0/24'))
          .to include(contained)
          .and include(contained_also)
          .and not_include(uncontained)
      end
    end
  end

  def factory_name
    described_class.name.underscore.to_sym
  end
end
