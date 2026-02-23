interface ApiHistoryJSON {
  day: string;
  accounts: string;
  uses: string;
}

interface ApiHashtagBase {
  id: string;
  name: string;
  url: string;
}

export interface ApiHashtagJSON extends ApiHashtagBase {
  history: [ApiHistoryJSON, ...ApiHistoryJSON[]];
  following?: boolean;
  featuring?: boolean;
}

export interface ApiFeaturedTagJSON extends ApiHashtagBase {
  statuses_count: number;
  last_status_at: string | null;
}

export function hashtagToFeaturedTag(tag: ApiHashtagJSON): ApiFeaturedTagJSON {
  return {
    id: tag.id,
    name: tag.name,
    url: tag.url,
    statuses_count: 0,
    last_status_at: null,
  };
}
