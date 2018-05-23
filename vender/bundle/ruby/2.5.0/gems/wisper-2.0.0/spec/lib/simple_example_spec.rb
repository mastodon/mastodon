class MyPublisher
  include Wisper::Publisher

  def do_something
    # ...
    broadcast(:bar, self)
    broadcast(:foo, self)
  end
end

describe 'simple publishing' do
  it 'subscribes listener to events' do
    listener = double('listener')
    expect(listener).to receive(:foo).with instance_of MyPublisher
    expect(listener).to receive(:bar).with instance_of MyPublisher

    my_publisher = MyPublisher.new
    my_publisher.subscribe(listener)
    my_publisher.do_something
  end
end
