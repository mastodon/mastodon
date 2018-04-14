Shindo.tests('read should timeout') do
  with_rackup('timeout.ru') do

    [false, true].each do |nonblock|
      tests("nonblock => #{nonblock} hits read_timeout").raises(Excon::Errors::Timeout) do
        connection = Excon.new('http://127.0.0.1:9292', :nonblock => nonblock)
        connection.request(:method => :get, :path => '/timeout', :read_timeout => 1)
      end
    end

  end
end
