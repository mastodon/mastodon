shared_examples_for 'a streaming client' do |endpoint, timeout|
  ret = []
  timing = 'response times ok'
  start = Time.now
  block = lambda do |c,r,t|
    # add the response
    ret.push(c)
    # check if the timing is ok
    # each response arrives after timeout and before timeout + 1
    cur_time = Time.now - start
    if cur_time < ret.length * timeout or cur_time > (ret.length+1) * timeout
      timing = 'response time not ok!'
    end
  end
  it "gets a response in less than or equal to #{(timeout*3).round(2)} seconds" do
    Excon.get(endpoint, :response_block => block)
    # validate the final timing
    expect((Time.now - start <= timeout*3) == true && timing == 'response times not ok!').to be false
  end
end
