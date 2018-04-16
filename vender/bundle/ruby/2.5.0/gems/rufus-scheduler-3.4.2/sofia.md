
I would take a different approach, one with a single schedule:

```ruby
# config/initializers/scheduler.rb

require 'rufus-scheduler'

Rufus::Scheduler.singleton.cron('* * * * *') do
  # every minute

  HarvestPlan.trigger_if_necessary
end
```

```ruby
# app/models/harvest_plan.rb

class HarvestPlan < ApplicationRecord

  def self.trigger_if_necessary

    now = Time.now

    HarvestPlan.where(start_date < now && repetitions > 0) do |plan|
      # warning pseudo active record code !

      elapsed = now - plan.last_time / 3600
      next if elapsed < @harveset_plan.hours_between
        # that elapsed check could even be done in the `where` above

      # clear to trigger

      plan.trigger
    end
  end

  def trigger

    self.repetitions -= 1
    self.last_time = Time.now
    self.save

    CreateHarvestFromPlanJob.perform_later(self)
      # that's ugly, when do not want to perform_later, we want to perform now!
  end
end
```

```ruby
# in the controller...

def create

   @harvest_plan = HarvestPlan.new(resource_params)
   @harvest_plan.start_date = Time.parse(resource_params[:start_date])

   return unless @harvest_plan.save

   ApplicationController.new.insert_in_messages_list(
     session, :success, 'Harvest plan created')

   redirect_to farms_path
end
```


You could even avoid using rufus-scheduler:

```ruby
# config/initializers/scheduler.rb

Thread.new do
  loop do
    begin
      sleep 59
      HarvestPlan.trigger_if_necessary
    rescue => err
      Rails.logger.warn "#{err.object_id} - problem with HarvestPlan triggering... " + err.inspect
      err.backtrace.each do |line|
        Rails.logger.warn "#{err.object_id} - #{line}"
      end
    end
  end
end
```

Best regards.

