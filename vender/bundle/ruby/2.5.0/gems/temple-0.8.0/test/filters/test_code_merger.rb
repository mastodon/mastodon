require 'helper'

describe Temple::Filters::CodeMerger do
  before do
    @filter = Temple::Filters::CodeMerger.new
  end

  it 'should merge serveral codes' do
    @filter.call([:multi,
      [:code, "a"],
      [:code, "b"],
      [:code, "c"]
    ]).should.equal [:code, "a; b; c"]
  end

  it 'should merge serveral codes around static' do
    @filter.call([:multi,
      [:code, "a"],
      [:code, "b"],
      [:static, "123"],
      [:code, "a"],
      [:code, "b"]
    ]).should.equal [:multi,
      [:code, "a; b"],
      [:static, "123"],
      [:code, "a; b"]
    ]
  end

  it 'should merge serveral codes with newlines' do
    @filter.call([:multi,
      [:code, "a"],
      [:code, "b"],
      [:newline],
      [:code, "c"]
    ]).should.equal [:code, "a; b\nc"]
  end
end
