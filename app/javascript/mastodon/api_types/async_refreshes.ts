export interface ApiAsyncRefreshJSON {
  async_refresh: {
    id: string;
    status: 'running' | 'finished';
    result_count: number;
  };
}
