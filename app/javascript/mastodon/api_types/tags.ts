interface ApiHistoryJSON {
  day: string;
  accounts: string;
  uses: string;
}

export interface ApiHashtagJSON {
  id: string;
  name: string;
  url: string;
  history: [ApiHistoryJSON, ...ApiHistoryJSON[]];
  following?: boolean;
}
