# config/initializers/i18n_pluralization.rb
# Sorbian pluralization for Rails I18n (Upper Sorbian: hsb, Lower Sorbian: dsb)
# Categories: :one, :two, :few, :other (cardinal)
# Rule (CLDR-like):
# - one  if n % 100 == 1
# - two  if n % 100 == 2
# - few  if n % 100 in 3..4
# - other otherwise
#
# Ordinals default to :other.

require 'i18n/backend/pluralization'
require 'i18n/backend/fallbacks'

I18n::Backend::Simple.include I18n::Backend::Pluralization
I18n::Backend::Simple.include I18n::Backend::Fallbacks

HSB_DSB_RULE = lambda do |n|
  i = n.to_i
  mod100 = i % 100
  return :one if mod100 == 1
  return :two if mod100 == 2
  return :few if (3..4).include?(mod100)
  :other
end

I18n.backend.store_translations(:hsb, i18n: { plural: { keys: %i[one two few other], rule: HSB_DSB_RULE } })
I18n.backend.store_translations(:dsb, i18n: { plural: { keys: %i[one two few other], rule: HSB_DSB_RULE } })

# Optional: explicit fallbacks (adjust to your preference)
begin
  I18n.fallbacks.map(hsb: %i[hsb de en], dsb: %i[dsb de en])
rescue NoMethodError
  # If fallbacks are not enabled, ignore
end
