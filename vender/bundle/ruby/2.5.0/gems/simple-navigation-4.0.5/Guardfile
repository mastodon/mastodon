guard :rspec, all_after_pass: true, failed_mode: :none do
  watch(%r{^spec/.+_spec\.rb$})
  watch(%r{^lib/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^spec/fake_app/.+\.rb$}) { 'spec/integration' }

  watch('spec/spec_helper.rb')  { 'spec' }
end
