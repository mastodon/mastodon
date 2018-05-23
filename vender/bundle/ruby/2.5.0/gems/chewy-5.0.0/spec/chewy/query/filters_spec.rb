require 'spec_helper'

describe Chewy::Query::Filters do
  def Bool(options) # rubocop:disable Naming/MethodName
    Chewy::Query::Nodes::Bool.new.tap do |bool|
      bool.must(*options[:must]) if options[:must].present?
      bool.must_not(*options[:must_not]) if options[:must_not].present?
      bool.should(*options[:should]) if options[:should].present?
    end
  end

  %w[field group and or not raw exists missing prefix regexp range equal query script].each do |method|
    define_method method.camelize do |*args|
      "Chewy::Query::Nodes::#{method.camelize}".constantize.new(*args)
    end
  end

  def query(&block)
    Chewy::Query::Filters.new(&block).__result__
  end

  context 'outer scope' do
    let(:email) { 'email' }
    specify { expect(query { email }).to be_eql Field(:email) }
    specify { expect(query { o { email } }).to eq('email') }
  end

  context 'field' do
    let(:email) { 'email' }
    specify { expect(query { f(:email) }).to be_eql Field(:email) }
    specify { expect(query { f { :email } }).to be_eql Field(:email) }
    specify { expect(query { f { email } }).to be_eql Field(:email) }
    specify { expect(query { email }).to be_eql Field(:email) }
    specify { expect(query { emails.first }).to be_eql Field('emails.first') }
    specify { expect(query { emails.first.second }).to be_eql Field('emails.first.second') }
  end

  context 'term' do
    specify { expect(query { email == 'email' }).to be_eql Equal(:email, 'email') }
    specify { expect(query { name != 'name' }).to be_eql Not(Equal(:name, 'name')) }
    specify { expect(query { email == %w[email1 email2] }).to be_eql Equal(:email, %w[email1 email2]) }
    specify { expect(query { email != %w[email1 email2] }).to be_eql Not(Equal(:email, %w[email1 email2])) }
    specify do
      expect(query { email(execution: :bool) == %w[email1 email2] })
        .to be_eql Equal(:email, %w[email1 email2], execution: :bool)
    end
    specify do
      expect(query { email(:bool) == %w[email1 email2] })
        .to be_eql Equal(:email, %w[email1 email2], execution: :bool)
    end
    specify do
      expect(query { email(:b) == %w[email1 email2] })
        .to be_eql Equal(:email, %w[email1 email2], execution: :bool)
    end
  end

  context 'bool' do
    specify { query { must(email == 'email') }.should be_eql Bool(must: [Equal(:email, 'email')]) }
    specify { query { must_not(email == 'email') }.should be_eql Bool(must_not: [Equal(:email, 'email')]) }
    specify { query { should(email == 'email') }.should be_eql Bool(should: [Equal(:email, 'email')]) }
    specify do
      query do
        must(email == 'email').should(address != 'address', age == 42)
          .must_not(sex == 'm').must(name == 'name')
      end.should be_eql Bool(
        must: [Equal(:email, 'email'), Equal(:name, 'name')],
        must_not: [Equal(:sex, 'm')],
        should: [Not(Equal(:address, 'address')), Equal(:age, 42)]
      )
    end
  end

  context 'exists' do
    specify { expect(query { email? }).to be_eql Exists(:email) }
    specify { expect(query { !!email? }).to be_eql Exists(:email) }
    specify { expect(query { emails.first? }).to be_eql Exists('emails.first') }
    specify { expect(query { !!emails.first? }).to be_eql Exists('emails.first') }
    specify { expect(query { emails != nil }).to be_eql Exists('emails') } # rubocop:disable Style/NonNilCheck
    specify { expect(query { emails.first != nil }).to be_eql Exists('emails.first') } # rubocop:disable Style/NonNilCheck
    specify { expect(query { !emails.nil? }).to be_eql Exists('emails') }
    specify { expect(query { !emails.first.nil? }).to be_eql Exists('emails.first') }
  end

  context 'missing' do
    specify { expect(query { !email }).to be_eql Missing(:email) }
    specify { expect(query { !email? }).to be_eql Missing(:email, null_value: true) }
    specify { expect(query { !emails.first }).to be_eql Missing('emails.first') }
    specify { expect(query { !emails.first? }).to be_eql Missing('emails.first', null_value: true) }
    specify { expect(query { emails == nil }).to be_eql Missing('emails', existence: false, null_value: true) } # rubocop:disable Style/NilComparison
    specify { expect(query { emails.first == nil }).to be_eql Missing('emails.first', existence: false, null_value: true) } # rubocop:disable Style/NilComparison
    specify { expect(query { emails.nil? }).to be_eql Missing('emails', existence: false, null_value: true) }
    specify { expect(query { emails.first.nil? }).to be_eql Missing('emails.first', existence: false, null_value: true) }
  end

  context 'range' do
    specify { expect(query { age > 42 }).to be_eql Range(:age, gt: 42) }
    specify { expect(query { age >= 42 }).to be_eql Range(:age, gt: 42, left_closed: true) }
    specify { expect(query { age < 42 }).to be_eql Range(:age, lt: 42) }
    specify { expect(query { age <= 42 }).to be_eql Range(:age, lt: 42, right_closed: true) }

    specify { expect(query { age == (30..42) }).to be_eql Range(:age, gt: 30, lt: 42) }
    specify { expect(query { age == [30..42] }).to be_eql Range(:age, gt: 30, lt: 42, left_closed: true, right_closed: true) }
    specify { expect(query { (age > 30) & (age < 42) }).to be_eql Range(:age, gt: 30, lt: 42) }
    specify { expect(query { (age > 30) & (age <= 42) }).to be_eql Range(:age, gt: 30, lt: 42, right_closed: true) }
    specify { expect(query { (age >= 30) & (age < 42) }).to be_eql Range(:age, gt: 30, lt: 42, left_closed: true) }
    specify { expect(query { (age >= 30) & (age <= 42) }).to be_eql Range(:age, gt: 30, lt: 42, right_closed: true, left_closed: true) }
    specify { expect(query { (age > 30) | (age < 42) }).to be_eql Or(Range(:age, gt: 30), Range(:age, lt: 42)) }
  end

  context 'prefix' do
    specify { expect(query { name =~ 'nam' }).to be_eql Prefix(:name, 'nam') }
    specify { expect(query { name !~ 'nam' }).to be_eql Not(Prefix(:name, 'nam')) }
  end

  context 'regexp' do
    specify { expect(query { name =~ /name/ }).to be_eql Regexp(:name, 'name') }
    specify { expect(query { name == /name/ }).to be_eql Regexp(:name, 'name') }
    specify { expect(query { name !~ /name/ }).to be_eql Not(Regexp(:name, 'name')) }
    specify { expect(query { name != /name/ }).to be_eql Not(Regexp(:name, 'name')) }
    specify { expect(query { name(:anystring, :intersection) =~ /name/ }).to be_eql Regexp(:name, 'name', flags: %w[anystring intersection]) }
  end

  context 'query' do
    let(:some_query) { 'some query' }
    specify { expect(query { q('some query') }).to be_eql Query('some query') }
    specify { expect(query { q { 'some query' } }).to be_eql Query('some query') }
    specify { expect(query { q { some_query } }).to be_eql Query('some query') }
  end

  context 'raw' do
    let(:raw_query) { {term: {name: 'name'}} }
    specify { expect(query { r(term: {name: 'name'}) }).to be_eql Raw(term: {name: 'name'}) }
    specify { expect(query { r { {term: {name: 'name'}} } }).to be_eql Raw(term: {name: 'name'}) }
    specify { expect(query { r { raw_query } }).to be_eql Raw(term: {name: 'name'}) }
  end

  context 'script' do
    let(:some_script) { 'some script' }
    specify { expect(query { s('some script') }).to be_eql Script('some script') }
    specify { expect(query { s('some script', param1: 42) }).to be_eql Script('some script', param1: 42) }
    specify { expect(query { s { 'some script' } }).to be_eql Script('some script') }
    specify { expect(query { s(param1: 42) { some_script } }).to be_eql Script('some script', param1: 42) }
  end

  context 'and or not' do
    specify do
      expect(query { (email == 'email') & (name == 'name') })
        .to be_eql And(Equal(:email, 'email'), Equal(:name, 'name'))
    end
    specify do
      expect(query { (email == 'email') | (name == 'name') })
        .to be_eql Or(Equal(:email, 'email'), Equal(:name, 'name'))
    end
    specify { expect(query { email != 'email' }).to be_eql Not(Equal(:email, 'email')) }

    specify do
      expect(query { (email == 'email') & (name == 'name') | (address != 'address') })
        .to be_eql Or(
          And(
            Equal(:email, 'email'),
            Equal(:name, 'name')
          ),
          Not(Equal(:address, 'address'))
        )
    end
    specify do
      expect(query { (email == 'email') & ((name == 'name') | (address != 'address')) })
        .to be_eql And(
          Equal(:email, 'email'),
          Or(
            Equal(:name, 'name'),
            Not(Equal(:address, 'address'))
          )
        )
    end
    specify do
      expect(query { (email == 'email') & ((name == 'name') & (address != 'address')) })
        .to be_eql And(
          Equal(:email, 'email'),
          Equal(:name, 'name'),
          Not(Equal(:address, 'address'))
        )
    end
    specify do
      expect(query { ((email == 'email') | (name == 'name')) | (address != 'address') })
        .to be_eql Or(
          Equal(:email, 'email'),
          Equal(:name, 'name'),
          Not(Equal(:address, 'address'))
        )
    end
    specify do
      expect(query { !((email == 'email') | (name == 'name')) })
        .to be_eql Not(Or(Equal(:email, 'email'), Equal(:name, 'name')))
    end
    specify do
      expect(query { !!((email == 'email') | (name == 'name')) })
        .to be_eql Or(Equal(:email, 'email'), Equal(:name, 'name'))
    end
  end
end
