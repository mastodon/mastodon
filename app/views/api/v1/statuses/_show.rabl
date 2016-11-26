attributes :id, :created_at, :in_reply_to_id, :is_private, :sensitive

node(:uri)              { |status| TagManager.instance.uri_for(status) }
node(:content)          { |status| Formatter.instance.format(status) }
node(:url)              { |status| TagManager.instance.url_for(status) }
node(:reblogs_count)    { |status| defined?(@reblogs_counts_map)    ? (@reblogs_counts_map[status.id]    || 0) : status.reblogs_count }
node(:favourites_count) { |status| defined?(@favourites_counts_map) ? (@favourites_counts_map[status.id] || 0) : status.favourites_count }

node(:current_user_id) { |status|
  current_user.id
}

node(:account_id) { |status|
  status.account_id
}

node(:private_recipient_id) { |status|
  status.private_recipient_id
}

node(:private_content) { |status|
  if status.is_private then
    if current_user.id == status.account_id || current_user.id == status.private_recipient_id then
      Formatter.instance.format(status, true)
    else
      nil
    end
  else
    nil
  end
}

node(:private_recipient) { |status|
  if status.is_private then
    if current_user.id == status.account_id || current_user.id == status.private_recipient_id then
      partial('api/v1/accounts/show', object: status.private_recipient)
    else
      nil
    end
  else
    nil
  end
}

child :account do
  extends 'api/v1/accounts/show'
end

child :media_attachments, object_root: false do
  extends 'api/v1/statuses/_media'
end

child :mentions, object_root: false do
  extends 'api/v1/statuses/_mention'
end

child :tags, object_root: false do
  extends 'api/v1/statuses/_tags'
end
