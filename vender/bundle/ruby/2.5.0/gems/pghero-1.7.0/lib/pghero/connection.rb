module PgHero
  class Connection < ActiveRecord::Base
    self.abstract_class = true
  end
end
