class RackApp
  attr_reader :last_value, :store_active

  def call(env)
    RequestStore.store[:foo] ||= 0
    RequestStore.store[:foo] += 1
    @last_value = RequestStore.store[:foo]
    @store_active = RequestStore.active?
    raise 'FAIL' if env[:error]

    [200, {}, ["response"]]
  end
end
