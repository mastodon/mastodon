import type { ApiAccountJSON } from './accounts';

export type ReportCategory = 'other' | 'spam' | 'legal' | 'violation';

export interface ApiReportJSON {
  id: string;
  action_taken: unknown;
  action_taken_at: unknown;
  category: ReportCategory;
  comment: string;
  forwarded: boolean;
  created_at: string;
  status_ids: string[];
  rule_ids: string[];
  target_account: ApiAccountJSON;
}
