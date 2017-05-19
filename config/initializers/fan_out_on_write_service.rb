Rails.configuration.x.fan_out_job_batch_size = ENV.fetch('FAN_OUT_JOB_BATCH_SIZE') { 1 }.to_i
