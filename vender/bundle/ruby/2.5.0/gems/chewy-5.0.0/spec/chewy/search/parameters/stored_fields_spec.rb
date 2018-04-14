require 'spec_helper'

describe Chewy::Search::Parameters::StoredFields do
  subject { described_class.new(%i[foo bar]) }

  describe '#initialize' do
    specify { expect(described_class.new.value).to eq(stored_fields: [], enabled: true) }
    specify { expect(described_class.new(nil).value).to eq(stored_fields: [], enabled: true) }
    specify { expect(described_class.new(:foo).value).to eq(stored_fields: %w[foo], enabled: true) }
    specify { expect(described_class.new([:foo, nil]).value).to eq(stored_fields: %w[foo], enabled: true) }
    specify { expect(described_class.new([:foo, 42]).value).to eq(stored_fields: %w[foo 42], enabled: true) }
    specify { expect(described_class.new(false).value).to eq(stored_fields: [], enabled: false) }
    specify { expect(described_class.new(true).value).to eq(stored_fields: [], enabled: true) }
  end

  describe '#replace!' do
    specify do
      expect { subject.replace!(nil) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: [], enabled: true)
    end

    specify do
      expect { subject.replace!(%i[foo baz]) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: %w[foo baz], enabled: true)
    end

    specify do
      expect { subject.replace!(false) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: [], enabled: false)
    end

    context do
      before { subject.update!(false) }

      specify do
        expect { subject.replace!(true) }
          .to change { subject.value }
          .from(stored_fields: %w[foo bar], enabled: false)
          .to(stored_fields: [], enabled: true)
      end
    end
  end

  describe '#update!' do
    specify do
      expect { subject.update!(nil) }
        .not_to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
    end

    specify do
      expect { subject.update!(%i[foo baz]) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: %w[foo bar baz], enabled: true)
    end

    specify do
      expect { subject.update!(false) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: %w[foo bar], enabled: false)
    end

    context do
      before { subject.update!(false) }

      specify do
        expect { subject.update!(true) }
          .to change { subject.value }
          .from(stored_fields: %w[foo bar], enabled: false)
          .to(stored_fields: %w[foo bar], enabled: true)
      end
    end
  end

  describe '#merge!' do
    specify do
      expect { subject.merge!(described_class.new) }
        .not_to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
    end

    specify do
      expect { subject.merge!(described_class.new(%i[foo baz])) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: %w[foo bar baz], enabled: true)
    end

    specify do
      expect { subject.merge!(described_class.new(:baz).tap { |i| i.update!(false) }) }
        .to change { subject.value }
        .from(stored_fields: %w[foo bar], enabled: true)
        .to(stored_fields: %w[foo bar baz], enabled: false)
    end

    context do
      before { subject.update!(false) }

      specify do
        expect { subject.merge!(described_class.new(:baz).tap { |i| i.update!(true) }) }
          .to change { subject.value }
          .from(stored_fields: %w[foo bar], enabled: false)
          .to(stored_fields: %w[foo bar baz], enabled: true)
      end
    end
  end

  describe '#render' do
    specify { expect(described_class.new.render).to be_nil }
    specify { expect(described_class.new(:foo).render).to eq(stored_fields: %w[foo]) }
    specify { expect(described_class.new(false).render).to eq(stored_fields: '_none_') }

    context do
      before { subject.update!(false) }
      specify { expect(subject.render).to eq(stored_fields: '_none_') }
    end
  end
end
