# frozen_string_literal: true

module ExponentialBackoff
  extend ActiveSupport::Concern

  included do
    #  # | Next retry backoff | Total waiting time
    # ---|--------------------|--------------------
    #  1 | 32                 | 32
    #  2 | 320                | 352
    #  3 | 1022               | 1374
    #  4 | 3060               | 4434
    #  5 | 6778               | 11212
    #  6 | 16088              | 27300
    #  7 | 37742              | 65042
    #  8 | 53799              | 118841
    #  9 | 105677             | 224518
    # 10 | 129972             | 354490
    # 11 | 270226             | 624716
    # 12 | 301127             | 925843
    # 13 | 287711             | 1213554
    # 14 | 616223             | 1829777
    # 15 | 607261             | 2437038
    # 16 | 1161984            | 3599022
    sidekiq_retry_in do |count|
      15 + 10 * (count**4) + rand(10 * (count**4))
    end
  end
end
