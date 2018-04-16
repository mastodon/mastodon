%w[4.0 4.1 4.2].each do |activesupport|
  appraise "rails.#{activesupport}.activerecord" do
    gem 'activerecord', "~> #{activesupport}.0"
    gem 'activesupport', "~> #{activesupport}.0"

    gem 'activejob', "~> #{activesupport}.0" if activesupport >= '4.2'
    gem 'resque', require: false
    gem 'shoryuken', require: false
    gem 'aws-sdk-sqs', require: false
    gem 'sidekiq', require: false

    gem 'kaminari', '~> 0.17.0', require: false
    gem 'will_paginate', require: false

    gem 'parallel', require: false
  end
end

%w[5.0 5.1].each do |activesupport|
  appraise "rails.#{activesupport}.activerecord" do
    gem 'activerecord', "~> #{activesupport}.0"
    gem 'activesupport', "~> #{activesupport}.0"

    gem 'activejob', "~> #{activesupport}.0"
    gem 'resque', require: false
    gem 'shoryuken', require: false
    gem 'aws-sdk-sqs', require: false
    gem 'sidekiq', require: false

    gem 'kaminari-core', '~> 1.1.0', require: false
    gem 'will_paginate', require: false

    gem 'parallel', require: false
  end
end

appraise 'rails.5.2.activerecord' do
  gem 'activerecord', '~> 5.2.0.rc1'
  gem 'activesupport', '~> 5.2.0.rc1'

  gem 'activejob', '~> 5.2.0.rc1'
  gem 'resque', require: false
  gem 'shoryuken', require: false
  gem 'aws-sdk-sqs', require: false
  gem 'sidekiq', require: false

  gem 'kaminari-core', '~> 1.1.0', require: false
  gem 'will_paginate', require: false

  gem 'parallel', require: false
end

appraise 'rails.4.2.mongoid.5.2' do
  gem 'mongoid', '~> 5.2.0'
  gem 'activesupport', '~> 4.2.0'

  gem 'activejob', '~> 4.2.0'
  gem 'resque', require: false
  gem 'shoryuken', require: false
  gem 'aws-sdk-sqs', require: false
  gem 'sidekiq', require: false

  gem 'kaminari', '~> 0.17.0', require: false
  gem 'will_paginate', require: false

  gem 'parallel', require: false
end

{'5.0' => '6.1', '5.1' => '6.3'}.each do |activesupport, mongoid|
  appraise "rails.#{activesupport}.mongoid.#{mongoid}" do
    gem 'mongoid', "~> #{mongoid}.0"
    gem 'activesupport', "~> #{activesupport}.0"

    gem 'activejob', "~> #{activesupport}.0"
    gem 'resque', require: false
    gem 'shoryuken', require: false
    gem 'aws-sdk-sqs', require: false
    gem 'sidekiq', require: false

    gem 'kaminari-core', '~> 1.1.0', require: false
    gem 'will_paginate', require: false

    gem 'parallel', require: false
  end
end

%w[4.45].each do |sequel|
  appraise "sequel.#{sequel}" do
    gem 'sequel', "~> #{sequel}.0"
    gem 'activesupport', '~> 5.1.0'

    gem 'kaminari-core', '~> 1.1.0', require: false
    gem 'will_paginate', require: false

    gem 'parallel', require: false
  end
end
