WITH domain_counts(domain, accounts_count)
AS (
  SELECT domain, COUNT(*) as accounts_count
  FROM accounts
  WHERE domain IS NOT NULL
  GROUP BY domain
)
SELECT domain, accounts_count
FROM domain_counts
UNION
SELECT domain_blocks.domain, COALESCE(domain_counts.accounts_count, 0)
FROM domain_blocks
LEFT OUTER JOIN domain_counts ON domain_counts.domain = domain_blocks.domain
UNION
SELECT domain_allows.domain, COALESCE(domain_counts.accounts_count, 0)
FROM domain_allows
LEFT OUTER JOIN domain_counts ON domain_counts.domain = domain_allows.domain
