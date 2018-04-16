require 'helper'

describe Temple::Filters::Eraser do
  it 'should respect keep' do
    eraser = Temple::Filters::Eraser.new(keep: [:a])
    eraser.call([:multi,
      [:a],
      [:b],
      [:c]
    ]).should.equal [:multi,
      [:a],
      [:multi],
      [:multi]
    ]
  end

  it 'should respect erase' do
    eraser = Temple::Filters::Eraser.new(erase: [:a])
    eraser.call([:multi,
      [:a],
      [:b],
      [:c]
    ]).should.equal [:multi,
      [:multi],
      [:b],
      [:c]
    ]
  end

  it 'should choose erase over keep' do
    eraser = Temple::Filters::Eraser.new(keep: [:a, :b], erase: [:a])
    eraser.call([:multi,
      [:a],
      [:b],
      [:c]
    ]).should.equal [:multi,
      [:multi],
      [:b],
      [:multi]
    ]
  end

  it 'should erase nested types' do
    eraser = Temple::Filters::Eraser.new(erase: [[:a, :b]])
    eraser.call([:multi,
      [:a, :a],
      [:a, :b],
      [:b]
    ]).should.equal [:multi,
      [:a, :a],
      [:multi],
      [:b]
    ]
  end
end
