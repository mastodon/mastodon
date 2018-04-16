require 'spec_helper'

describe MethodSource do

  describe "source_location (testing 1.8 implementation)" do
    it 'should return correct source_location for a method' do
      expect(method(:hello).source_location.first).to match(/spec_helper/)
    end

    it 'should not raise for immediate instance methods' do
      [Symbol, Integer, TrueClass, FalseClass, NilClass].each do |immediate_class|
        expect do
          immediate_class.instance_method(:to_s).source_location
        end.not_to raise_error
      end
    end

    it 'should not raise for immediate methods' do
      [:a, 1, true, false, nil].each do |immediate|
        expect do
          immediate.method(:to_s).source_location
        end.not_to raise_error
      end
    end
  end

  before do
    @hello_module_source = "  def hello; :hello_module; end\n"
    @hello_singleton_source = "def $o.hello; :hello_singleton; end\n"
    @hello_source = "def hello; :hello; end\n"
    @hello_comment = "# A comment for hello\n# It spans two lines and is indented by 2 spaces\n"
    @lambda_comment = "# This is a comment for MyLambda\n"
    @lambda_source = "MyLambda = lambda { :lambda }\n"
    @proc_source = "MyProc = Proc.new { :proc }\n"
    @hello_instance_evaled_source = "  def hello_\#{name}(*args)\n    send_mesg(:\#{name}, *args)\n  end\n"
    @hello_instance_evaled_source_2 = "  def \#{name}_two()\n    if 44\n      45\n    end\n  end\n"
    @hello_class_evaled_source = "  def hello_\#{name}(*args)\n    send_mesg(:\#{name}, *args)\n  end\n"
    @hi_module_evaled_source = "  def hi_\#{name}\n    @var = \#{name}\n  end\n"
  end

  it 'should define methods on Method and UnboundMethod and Proc' do
    expect(Method.method_defined?(:source)).to be_truthy
    expect(UnboundMethod.method_defined?(:source)).to be_truthy
    expect(Proc.method_defined?(:source)).to be_truthy
  end

  describe "Methods" do
    it 'should return source for method' do
      expect(method(:hello).source).to eq(@hello_source)
    end

    it 'should return source for a method defined in a module' do
      expect(M.instance_method(:hello).source).to eq(@hello_module_source)
    end

    it 'should return source for a singleton method as an instance method' do
      expect(class << $o
        self
      end.instance_method(:hello).source).to eq(@hello_singleton_source)
    end

    it 'should return source for a singleton method' do
      expect($o.method(:hello).source).to eq(@hello_singleton_source)
    end

    it 'should return a comment for method' do
      expect(method(:hello).comment).to eq(@hello_comment)
    end

    # These tests fail because of http://jira.codehaus.org/browse/JRUBY-4576
    unless defined?(RUBY_ENGINE) && RUBY_ENGINE == "jruby"
      it 'should return source for an *_evaled method' do
        expect(M.method(:hello_name).source).to eq(@hello_instance_evaled_source)
        expect(M.method(:name_two).source).to eq(@hello_instance_evaled_source_2)
        expect(M.instance_method(:hello_name).source).to eq(@hello_class_evaled_source)
        expect(M.instance_method(:hi_name).source).to eq(@hi_module_evaled_source)
      end
    end

    it "should raise error for evaled methods that do not pass __FILE__ and __LINE__ + 1 as its arguments" do
      expect do
        M.instance_method(:name_three).source
      end.to raise_error(MethodSource::SourceNotFoundError)
    end

    if !is_rbx?
      it 'should raise for C methods' do
        expect do
          method(:puts).source
        end.to raise_error(MethodSource::SourceNotFoundError)
      end
    end
  end

  # if RUBY_VERSION =~ /1.9/ || is_rbx?
  describe "Lambdas and Procs" do
    it 'should return source for proc' do
      expect(MyProc.source).to eq(@proc_source)
    end

    it 'should return an empty string if there is no comment' do
      expect(MyProc.comment).to eq('')
    end

    it 'should return source for lambda' do
      expect(MyLambda.source).to eq(@lambda_source)
    end

    it 'should return comment for lambda' do
      expect(MyLambda.comment).to eq(@lambda_comment)
    end
  end
  # end
  describe "Comment tests" do
    before do
      @comment1 = "# a\n# b\n"
      @comment2 = "# a\n# b\n"
      @comment3 = "# a\n#\n# b\n"
      @comment4 = "# a\n# b\n"
      @comment5 = "# a\n# b\n# c\n# d\n"
    end

    it "should correctly extract multi-line comments" do
      expect(method(:comment_test1).comment).to eq(@comment1)
    end

    it "should correctly strip leading whitespace before comments" do
      expect(method(:comment_test2).comment).to eq(@comment2)
    end

    it "should keep empty comment lines" do
      expect(method(:comment_test3).comment).to eq(@comment3)
    end

    it "should ignore blank lines between comments" do
      expect(method(:comment_test4).comment).to eq(@comment4)
    end

    it "should align all comments to same indent level" do
      expect(method(:comment_test5).comment).to eq(@comment5)
    end
  end
end
