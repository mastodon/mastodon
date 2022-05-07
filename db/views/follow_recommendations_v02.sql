SELECT
  account_id,
  sum(rank) AS rank,
  array_agg(reason) AS reason
FROM (
  SELECT
    account_summaries.account_id AS account_id,
    count(follows.id) / (1.0 + count(follows.id)) AS rank,
    'most_followed' AS reason
  FROM follows
  INNER JOIN account_summaries ON account_summaries.account_id = follows.target_account_id
  INNER JOIN users ON users.account_id = follows.account_id
  LEFT OUTER JOIN follow_recommendation_suppressions ON follow_recommendation_suppressions.account_id = follows.target_account_id
  WHERE users.current_sign_in_at >= (now() - interval '30 days')
    AND account_summaries.sensitive = 'f'
    AND follow_recommendation_suppressions.id IS NULL
  GROUP BY account_summaries.account_id
  HAVING count(follows.id) >= 5
  UNION ALL
  SELECT account_summaries.account_id AS account_id,
         sum(status_stats.reblogs_count + status_stats.favourites_count) / (1.0 + sum(status_stats.reblogs_count + status_stats.favourites_count)) AS rank,
         'most_interactions' AS reason
  FROM status_stats
  INNER JOIN statuses ON statuses.id = status_stats.status_id
  INNER JOIN account_summaries ON account_summaries.account_id = statuses.account_id
  LEFT OUTER JOIN follow_recommendation_suppressions ON follow_recommendation_suppressions.account_id = statuses.account_id
  WHERE statuses.id >= ((date_part('epoch', now() - interval '30 days') * 1000)::bigint << 16)
    AND account_summaries.sensitive = 'f'
    AND follow_recommendation_suppressions.id IS NULL
  GROUP BY account_summaries.account_id
  HAVING sum(status_stats.reblogs_count + status_stats.favourites_count) >= 5
) t0
GROUP BY account_id
ORDER BY rank DESC
