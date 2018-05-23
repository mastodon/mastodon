require 'spec_helper'

describe 'Plural cache' do
  it 'caches pluralizations' do
    cache = Paperclip::Interpolations::PluralCache.new
    symbol = :box

    first = cache.pluralize_symbol(symbol)
    second = cache.pluralize_symbol(symbol)
    expect(first).to equal(second)
  end

  it 'caches pluralizations and underscores' do
    class BigBox ; end
    cache = Paperclip::Interpolations::PluralCache.new
    klass = BigBox

    first = cache.underscore_and_pluralize_class(klass)
    second = cache.underscore_and_pluralize_class(klass)
    expect(first).to equal(second)
  end

  it 'pluralizes words' do
    cache = Paperclip::Interpolations::PluralCache.new
    symbol = :box

    expect(cache.pluralize_symbol(symbol)).to eq("boxes")
  end

  it 'pluralizes and underscore class names' do
    class BigBox ; end
    cache = Paperclip::Interpolations::PluralCache.new
    klass = BigBox

    expect(cache.underscore_and_pluralize_class(klass)).to eq("big_boxes")
  end
end
