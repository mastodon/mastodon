import api, { apiRequestGet, getAsyncRefreshHeader } from '../api';
import type { ApiAccountJSON } from '../api_types/accounts';
import type { ApiStatusJSON } from '../api_types/statuses';
import type { AnnualReport } from '../models/annual_report';

export type ApiAnnualReportState =
  | 'available'
  | 'generating'
  | 'eligible'
  | 'ineligible';

export const apiGetAnnualReportState = async (year: number) => {
  const response = await api().get<{ state: ApiAnnualReportState }>(
    `/api/v1/annual_reports/${year}/state`,
  );

  return {
    state: response.data.state,
    refresh: getAsyncRefreshHeader(response),
  };
};

export const apiRequestGenerateAnnualReport = async (year: number) => {
  const response = await api().post(`/api/v1/annual_reports/${year}/generate`);

  return {
    refresh: getAsyncRefreshHeader(response),
  };
};

export interface ApiAnnualReportResponse {
  annual_reports: AnnualReport[];
  accounts: ApiAccountJSON[];
  statuses: ApiStatusJSON[];
}

export const apiGetAnnualReport = (year: number) =>
  apiRequestGet<ApiAnnualReportResponse>(`v1/annual_reports/${year}`);
