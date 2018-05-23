run lambda { |env|
  [200, {"Content-Type" => "text/plain"}, [Redis.current.randomkey]]
}
