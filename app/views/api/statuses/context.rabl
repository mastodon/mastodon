object false

node :ancestors do
  @ancestors.map do |status|
    partial('api/statuses/show', object: status)
  end
end

node :descendants do
  @descendants.map do |status|
    partial('api/statuses/show', object: status)
  end
end
