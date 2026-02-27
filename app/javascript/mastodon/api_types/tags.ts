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
  statuses_count: string;
  last_status_at: string | null;
}
