require 'spec_helper'

shared_examples :query_storage do |param_name|
  subject { described_class.new(must: {foo: 'bar'}, should: {moo: 'baz'}) }

  describe '#initialize' do
    specify { expect(described_class.new.value.to_h).to eq(must: [], should: [], must_not: [], minimum_should_match: nil) }
    specify { expect(described_class.new(nil).value.to_h).to eq(must: [], should: [], must_not: [], minimum_should_match: nil) }
    specify { expect(described_class.new(foobar: {}).value.to_h).to eq(must: [{foobar: {}}], should: [], must_not: [], minimum_should_match: nil) }
    specify { expect(described_class.new(must: {}, should: {}, must_not: {}).value.to_h).to eq(must: [], should: [], must_not: [], minimum_should_match: nil) }
    specify do
      expect(described_class.new(must: {foo: 'bar'}, should: {foo: 'bar'}, foobar: {}).value.to_h)
        .to eq(must: [{foo: 'bar'}], should: [{foo: 'bar'}], must_not: [], minimum_should_match: nil)
    end
    specify { expect(subject.value.to_h).to eq(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil) }
    specify { expect(described_class.new(proc { match foo: 'bar' }).value.to_h).to eq(must: [match: {foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil) }
    specify { expect(described_class.new(must: proc { match foo: 'bar' }).value.to_h).to eq(must: [match: {foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil) }
    specify { expect(described_class.new(minimum_should_match: 3).value.to_h).to eq(must: [], should: [], must_not: [], minimum_should_match: 3) }
    specify { expect(described_class.new(must: {foo: 'bar'}, minimum_should_match: 3).value.to_h).to eq(must: [{foo: 'bar'}], should: [], must_not: [], minimum_should_match: 3) }
    specify do
      expect(described_class.new(must: [proc { match foo: 'bar' }, {moo: 'baz'}]).value.to_h)
        .to eq(must: [{match: {foo: 'bar'}}, {moo: 'baz'}], should: [], must_not: [], minimum_should_match: nil)
    end
  end

  describe '#must' do
    specify do
      expect { subject.must(moo: 'baz') }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}, {moo: 'baz'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.must(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end
  end

  describe '#should' do
    specify do
      expect { subject.should(foo: 'bar') }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}, {foo: 'bar'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.should(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end
  end

  describe '#must_not' do
    specify do
      expect { subject.must_not(moo: 'baz') }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [{moo: 'baz'}], minimum_should_match: nil)
    end

    specify do
      expect { subject.must_not(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end
  end

  describe '#and' do
    specify do
      expect { subject.and(moo: 'baz') }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, {moo: 'baz'}], should: [], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.and([{moo: 'baz'}, {doo: 'scooby'}]) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, bool: {must: [{moo: 'baz'}, {doo: 'scooby'}]}], should: [], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.and(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.and(should: {foo: 'bar'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, {bool: {should: {foo: 'bar'}}}], should: [], must_not: [], minimum_should_match: nil)
    end

    context do
      subject { described_class.new(must: {foo: 'bar'}) }

      specify do
        expect { subject.and(moo: 'baz') }
          .to change { subject.value.to_h }
          .from(must: [{foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil)
          .to(must: [{foo: 'bar'}, {moo: 'baz'}], should: [], must_not: [], minimum_should_match: nil)
      end
    end
  end

  describe '#or' do
    specify do
      expect { subject.or(moo: 'baz') }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [], should: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, {moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.or([{moo: 'baz'}, {doo: 'scooby'}]) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [], should: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, bool: {must: [{moo: 'baz'}, {doo: 'scooby'}]}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.or(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.or(should: {foo: 'bar'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [], should: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, {bool: {should: {foo: 'bar'}}}], must_not: [], minimum_should_match: nil)
    end

    context do
      subject { described_class.new(must: {foo: 'bar'}) }

      specify do
        expect { subject.or(moo: 'baz') }
          .to change { subject.value.to_h }
          .from(must: [{foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil)
          .to(must: [], should: [{foo: 'bar'}, {moo: 'baz'}], must_not: [], minimum_should_match: nil)
      end
    end
  end

  describe '#not' do
    specify do
      expect { subject.not(moo: 'baz') }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [{moo: 'baz'}], minimum_should_match: nil)
    end

    specify do
      expect { subject.not([{moo: 'baz'}, {doo: 'scooby'}]) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [{bool: {must: [{moo: 'baz'}, {doo: 'scooby'}]}}], minimum_should_match: nil)
    end

    specify do
      expect { subject.not(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.not(should: {foo: 'bar'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [{bool: {should: {foo: 'bar'}}}], minimum_should_match: nil)
    end

    context do
      subject { described_class.new(must: {foo: 'bar'}) }

      specify do
        expect { subject.not(moo: 'baz') }
          .to change { subject.value.to_h }
          .from(must: [{foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil)
          .to(must: [{foo: 'bar'}], should: [], must_not: [{moo: 'baz'}], minimum_should_match: nil)
      end
    end
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(must: proc { match foo: 'bar' }) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [match: {foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.replace!(should: {foo: 'bar'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [], should: [{foo: 'bar'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.replace!(foobar: {foo: 'bar'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foobar: {foo: 'bar'}}], should: [], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [], should: [], must_not: [], minimum_should_match: nil)
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(must: proc { match foo: 'bar' }) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}, {match: {foo: 'bar'}}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.update!(must_not: {moo: 'baz'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [{moo: 'baz'}], minimum_should_match: nil)
    end

    specify do
      expect { subject.update!(foobar: {foo: 'bar'}) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{foo: 'bar'}, {foobar: {foo: 'bar'}}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    context 'minimum_should_match' do
      specify do
        expect { subject.update!(minimum_should_match: 2) }
          .to change { subject.value.to_h }
          .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
          .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 2)
      end

      context do
        before { subject.update!(minimum_should_match: 2) }

        specify do
          expect { subject.update!(minimum_should_match: 3) }
            .to change { subject.value.to_h }
            .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 2)
            .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 3)
        end

        specify do
          expect { subject.update!(minimum_should_match: nil) }
            .to change { subject.value.to_h }
            .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 2)
            .to(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        end
      end
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new(moo: 'baz')) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, {moo: 'baz'}], should: [], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
    end

    specify do
      expect { subject.merge!(described_class.new(should: {foo: 'bar'})) }
        .to change { subject.value.to_h }
        .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
        .to(must: [{bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}}, {bool: {should: {foo: 'bar'}}}], should: [], must_not: [], minimum_should_match: nil)
    end

    context do
      subject { described_class.new(must: {foo: 'bar'}) }

      specify do
        expect { subject.merge!(described_class.new(moo: 'baz')) }
          .to change { subject.value.to_h }
          .from(must: [{foo: 'bar'}], should: [], must_not: [], minimum_should_match: nil)
          .to(must: [{foo: 'bar'}, {moo: 'baz'}], should: [], must_not: [], minimum_should_match: nil)
      end
    end

    context 'minimum_should_match' do
      specify do
        expect { subject.merge!(described_class.new(minimum_should_match: 2)) }
          .not_to change { subject.value.to_h }
          .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: nil)
      end

      context do
        before { subject.update!(minimum_should_match: 2) }

        specify do
          expect { subject.merge!(described_class.new(must: {doo: 'scooby'}, minimum_should_match: 3)) }
            .to change { subject.value.to_h }
            .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 2)
            .to(must: [
              {bool: {must: {foo: 'bar'}, should: {moo: 'baz'}, minimum_should_match: 2}},
              {doo: 'scooby'}
            ], should: [], must_not: [], minimum_should_match: nil)
        end

        specify do
          expect { subject.merge!(described_class.new(should: {doo: 'scooby'}, minimum_should_match: 3)) }
            .to change { subject.value.to_h }
            .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 2)
            .to(must: [
              {bool: {must: {foo: 'bar'}, should: {moo: 'baz'}, minimum_should_match: 2}},
              {bool: {should: {doo: 'scooby'}, minimum_should_match: 3}}
            ], should: [], must_not: [], minimum_should_match: nil)
        end

        specify do
          expect { subject.merge!(described_class.new(minimum_should_match: nil)) }
            .not_to change { subject.value.to_h }
            .from(must: [{foo: 'bar'}], should: [{moo: 'baz'}], must_not: [], minimum_should_match: 2)
        end
      end
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }

    specify do
      expect(described_class.new(must: [{foo: 'bar'}]).render)
        .to eq(param_name => {foo: 'bar'})
    end

    specify do
      expect(described_class.new(must: {foo: 'bar'}, minimum_should_match: 2).render)
        .to eq(param_name => {foo: 'bar'})
    end

    specify do
      expect(described_class.new(should: {foo: 'bar'}, minimum_should_match: 2).render)
        .to eq(param_name => {bool: {should: {foo: 'bar'}, minimum_should_match: 2}})
    end

    specify do
      expect(described_class.new(must_not: {foo: 'bar'}, minimum_should_match: 2).render)
        .to eq(param_name => {bool: {must_not: {foo: 'bar'}}})
    end

    if param_name == :filter
      specify do
        expect(described_class.new(must: [{foo: 'bar'}, {moo: 'baz'}]).render)
          .to eq(param_name => [{foo: 'bar'}, {moo: 'baz'}])
      end
    else
      specify do
        expect(described_class.new(must: [{foo: 'bar'}, {moo: 'baz'}]).render)
          .to eq(param_name => {bool: {must: [{foo: 'bar'}, {moo: 'baz'}]}})
      end
    end

    specify do
      expect(subject.render)
        .to eq(param_name => {bool: {must: {foo: 'bar'}, should: {moo: 'baz'}}})
    end
  end
end
