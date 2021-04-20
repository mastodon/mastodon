SELECT
  accounts.id AS account_id,
  mode() WITHIN GROUP (ORDER BY language ASC) AS language,
  mode() WITHIN GROUP (ORDER BY sensitive ASC) AS sensitive
FROM accounts
CROSS JOIN LATERAL (
  SELECT
    statuses.account_id,
    statuses.language,
    statuses.sensitive
  FROM statuses
  WHERE statuses.account_id = accounts.id
    AND statuses.deleted_at IS NULL
  ORDER BY statuses.id DESC
  LIMIT 20
) t0
WHERE accounts.suspended_at IS NULL
  AND accounts.silenced_at IS NULL
  AND accounts.moved_to_account_id IS NULL
  AND accounts.discoverable = 't'
  AND accounts.locked = 'f'
GROUP BY accounts.id
