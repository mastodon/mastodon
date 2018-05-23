require 'helper'

describe Temple::Filters::StaticMerger do
  before do
    @filter = Temple::Filters::StaticMerger.new
  end

  it 'should merge serveral statics' do
    @filter.call([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:static, "Good night"]
    ]).should.equal [:static, "Hello World, Good night"]
  end

  it 'should merge serveral statics around code' do
    @filter.call([:multi,
      [:static, "Hello "],
      [:static, "World!"],
      [:code, "123"],
      [:static, "Good night, "],
      [:static, "everybody"]
    ]).should.equal [:multi,
      [:static, "Hello World!"],
      [:code, "123"],
      [:static, "Good night, everybody"]
    ]
  end

  it 'should merge serveral statics across newlines' do
    @filter.call([:multi,
      [:static, "Hello "],
      [:static, "World, "],
      [:newline],
      [:static, "Good night"]
    ]).should.equal [:multi,
      [:static, "Hello World, Good night"],
      [:newline]
    ]
  end
end
