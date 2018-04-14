require 'spec_helper'

describe Chewy::Type::Import::JournalBuilder, :orm do
  before do
    stub_model(:country)
    stub_index 'namespace/places' do
      define_type :city
      define_type Country
    end
    Timecop.freeze(time)
  end
  after { Timecop.return }

  let(:time) { Time.parse('2017-07-14 12:00Z') }

  let(:type) { Namespace::PlacesIndex::City }
  let(:index) { [] }
  let(:delete) { [] }
  subject { described_class.new(type, index: index, delete: delete) }

  describe '#bulk_body' do
    specify { expect(subject.bulk_body).to eq([]) }

    context do
      let(:index) { [{id: 1, name: 'City'}] }
      specify do
        expect(subject.bulk_body).to eq([{
          index: {
            _index: 'chewy_journal',
            _type: 'journal',
            data: {
              'index_name' => 'namespace/places',
              'type_name' => 'city',
              'action' => 'index',
              'references' => [Base64.encode64('{"id":1,"name":"City"}')],
              'created_at' => time.as_json
            }
          }
        }])
      end
    end

    context do
      let(:delete) { [{id: 1, name: 'City'}] }
      specify do
        expect(subject.bulk_body).to eq([{
          index: {
            _index: 'chewy_journal',
            _type: 'journal',
            data: {
              'index_name' => 'namespace/places',
              'type_name' => 'city',
              'action' => 'delete',
              'references' => [Base64.encode64('{"id":1,"name":"City"}')],
              'created_at' => time.as_json
            }
          }
        }])
      end
    end

    context do
      let(:type) { Namespace::PlacesIndex::Country }
      let(:index) { [Country.new(id: 1, name: 'City')] }
      let(:delete) { [Country.new(id: 2, name: 'City')] }
      specify do
        expect(subject.bulk_body).to eq([{
          index: {
            _index: 'chewy_journal',
            _type: 'journal',
            data: {
              'index_name' => 'namespace/places',
              'type_name' => 'country',
              'action' => 'index',
              'references' => [Base64.encode64('1')],
              'created_at' => time.as_json
            }
          }
        }, {
          index: {
            _index: 'chewy_journal',
            _type: 'journal',
            data: {
              'index_name' => 'namespace/places',
              'type_name' => 'country',
              'action' => 'delete',
              'references' => [Base64.encode64('2')],
              'created_at' => time.as_json
            }
          }
        }])
      end
    end
  end
end
