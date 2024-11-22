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
  by_reblogs: number;
  by_favourites: number;
  by_replies: number;
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

export interface AnnualReport {
  year: number;
  schema_version: number;
  data: AnnualReportV1;
}
