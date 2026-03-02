export interface Percentiles {
  followers: number;
  statuses: number;
}

export interface NameAndCount {
  name: string;
  count: number;
}

export interface TimeSeriesMonth {
  month: number;
  statuses: number;
  following: number;
  followers: number;
}

export interface TopStatuses {
  by_reblogs: string;
  by_favourites: string;
  by_replies: string;
}

export type Archetype =
  | 'lurker'
  | 'booster'
  | 'pollster'
  | 'replier'
  | 'oracle';

interface AnnualReportV1 {
  most_used_apps: NameAndCount[];
  percentiles: Percentiles;
  top_hashtags: NameAndCount[];
  top_statuses: TopStatuses;
  time_series: TimeSeriesMonth[];
  archetype: Archetype;
}

interface AnnualReportV2 {
  archetype: Archetype;
  time_series: TimeSeriesMonth[];
  top_hashtags: NameAndCount[];
  top_statuses: TopStatuses;
}

export type AnnualReport = {
  year: number;
} & (
  | {
      schema_version: 1;
      data: AnnualReportV1;
    }
  | {
      schema_version: 2;
      data: AnnualReportV2;
      share_url: string | null;
      account_id: string;
    }
);
