SELECT
  account_id,
  sum(rank) AS rank,
  array_agg(reason) AS reason
FROM (
  SELECT
    accounts.id AS account_id,
    count(follows.id) / (1.0 + count(follows.id)) AS rank,
    'most_followed' AS reason
  FROM follows
  INNER JOIN accounts ON accounts.id = follows.target_account_id
  INNER JOIN users ON users.account_id = follows.account_id
  WHERE users.current_sign_in_at >= (now() - interval '30 days')
    AND accounts.suspended_at IS NULL
    AND accounts.moved_to_account_id IS NULL
    AND accounts.silenced_at IS NULL
    AND accounts.locked = 'f'
    AND accounts.discoverable = 't'
  GROUP BY accounts.id
  HAVING count(follows.id) >= 5
  UNION ALL
  SELECT accounts.id AS account_id,
         sum(status_stats.reblogs_count + status_stats.favourites_count) / (1.0 + sum(status_stats.reblogs_count + status_stats.favourites_count)) AS rank,
         'most_interactions' AS reason
  FROM status_stats
  INNER JOIN statuses ON statuses.id = status_stats.status_id
  INNER JOIN accounts ON accounts.id = statuses.account_id
  WHERE statuses.id >= ((date_part('epoch', now() - interval '30 days') * 1000)::bigint << 16)
    AND accounts.suspended_at IS NULL
    AND accounts.moved_to_account_id IS NULL
    AND accounts.silenced_at IS NULL
    AND accounts.locked = 'f'
    AND accounts.discoverable = 't'
  GROUP BY accounts.id
  HAVING sum(status_stats.reblogs_count + status_stats.favourites_count) >= 5
) t0
GROUP BY account_id
ORDER BY rank DESC
