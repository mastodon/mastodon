object @follow

child :target_account => :target_account do
  extends('api/accounts/show')
end
