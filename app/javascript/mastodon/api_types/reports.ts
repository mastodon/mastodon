import type { ApiAccountJSON } from './accounts';

export type ReportCategory = 'other' | 'spam' | 'legal' | 'violation';

export interface BaseApiReportJSON {
  id: string;
  action_taken: unknown;
  action_taken_at: unknown;
  category: ReportCategory;
  comment: string;
  forwarded: boolean;
  created_at: string;
  status_ids: string[];
  rule_ids: string[];
}

export interface ApiReportJSON extends BaseApiReportJSON {
  target_account: ApiAccountJSON;
}

export interface ShallowApiReportJSON extends BaseApiReportJSON {
  target_account_id: string;
}
