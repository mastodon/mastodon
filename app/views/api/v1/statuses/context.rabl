object @context

node :ancestors do |context|
  partial 'api/v1/statuses/index', object: context.ancestors
end

node :descendants do |context|
  partial 'api/v1/statuses/index', object: context.descendants
end
