shared_examples 'RecentOrderable' do |fabricator|
  describe 'paginate_by_recent' do
    it 'limits by number' do
      Fabricate(fabricator)
      specified = Fabricate(fabricator)

      a = described_class.paginate_by_recent(1).to_a

      expect(a.size).to eq 1
      expect(a[0]).to eq specified
    end

    it 'limits by max ID' do
      min = Fabricate(fabricator)
      max = Fabricate(fabricator)

      a = described_class.paginate_by_recent(2, max.id).to_a

      expect(a.size).to eq 1
      expect(a[0]).to eq min
    end

    it 'limits by min ID' do
      min = Fabricate(fabricator)
      max = Fabricate(fabricator)

      a = described_class.paginate_by_recent(2, nil, min.id).to_a

      expect(a.size).to eq 1
      expect(a[0]).to eq max
    end
  end

  describe 'recent' do
    it 'sorts so that more recent follows comes earlier' do
      old = Fabricate(fabricator)
      recent = Fabricate(fabricator)
      old.save!
      recent.save!

      a = described_class.recent.to_a

      expect(a.size).to eq 2
      expect(a[0]).to eq recent
      expect(a[1]).to eq old
    end
  end
end
