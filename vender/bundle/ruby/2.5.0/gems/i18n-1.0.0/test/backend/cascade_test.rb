require 'test_helper'

class I18nBackendCascadeTest < I18n::TestCase
  class Backend < I18n::Backend::Simple
    include I18n::Backend::Cascade
  end

  def setup
    super
    I18n.backend = Backend.new
    store_translations(:en, :foo => 'foo', :bar => { :baz => 'baz' })
    @cascade_options = { :step => 1, :offset => 1, :skip_root => false }
  end

  def lookup(key, options = {})
    I18n.t(key, options.merge(:cascade => @cascade_options))
  end

  test "still returns an existing translation as usual" do
    assert_equal 'foo', lookup(:foo)
    assert_equal 'baz', lookup(:'bar.baz')
  end

  test "falls back by cutting keys off the end of the scope" do
    assert_equal 'foo', lookup(:foo, :scope => :'missing')
    assert_equal 'foo', lookup(:foo, :scope => :'missing.missing')
    assert_equal 'baz', lookup(:baz, :scope => :'bar.missing')
    assert_equal 'baz', lookup(:baz, :scope => :'bar.missing.missing')
  end

  test "raises I18n::MissingTranslationData exception when no translation was found" do
    assert_raise(I18n::MissingTranslationData) { lookup(:'foo.missing', :raise => true) }
    assert_raise(I18n::MissingTranslationData) { lookup(:'bar.baz.missing', :raise => true) }
    assert_raise(I18n::MissingTranslationData) { lookup(:'missing.bar.baz', :raise => true) }
  end

  test "cascades before evaluating the default" do
    assert_equal 'foo', lookup(:foo, :scope => :missing, :default => 'default')
  end

  test "cascades defaults, too" do
    assert_equal 'foo', lookup(nil, :default => [:'missing.missing', :'missing.foo'])
  end

  test "works with :offset => 2 and a single key" do
    @cascade_options[:offset] = 2
    lookup(:foo)
  end

  test "assemble required fallbacks for ActiveRecord validation messages" do
    store_translations(:en,
      :errors => {
        :odd => 'errors.odd',
        :reply => { :title => { :blank => 'errors.reply.title.blank'   }, :taken  => 'errors.reply.taken'  },
        :topic => { :title => { :format => 'errors.topic.title.format' }, :length => 'errors.topic.length' }
      }
    )
    assert_equal 'errors.reply.title.blank',  lookup(:'errors.reply.title.blank',  :default => :'errors.topic.title.blank')
    assert_equal 'errors.reply.taken',        lookup(:'errors.reply.title.taken',  :default => :'errors.topic.title.taken')
    assert_equal 'errors.topic.title.format', lookup(:'errors.reply.title.format', :default => :'errors.topic.title.format')
    assert_equal 'errors.topic.length',       lookup(:'errors.reply.title.length', :default => :'errors.topic.title.length')
    assert_equal 'errors.odd',                lookup(:'errors.reply.title.odd',    :default => :'errors.topic.title.odd')
  end

  test "assemble action view translation helper lookup cascade" do
    @cascade_options[:offset] = 2

    store_translations(:en,
      :menu => { :show => 'menu.show' },
      :namespace => {
        :menu => { :new => 'namespace.menu.new' },
        :controller => {
          :menu => { :edit => 'namespace.controller.menu.edit' },
          :action => {
            :menu => { :destroy => 'namespace.controller.action.menu.destroy' }
          }
        }
      }
    )

    assert_equal 'menu.show',                                lookup(:'namespace.controller.action.menu.show')
    assert_equal 'namespace.menu.new',                       lookup(:'namespace.controller.action.menu.new')
    assert_equal 'namespace.controller.menu.edit',           lookup(:'namespace.controller.action.menu.edit')
    assert_equal 'namespace.controller.action.menu.destroy', lookup(:'namespace.controller.action.menu.destroy')
  end
end
