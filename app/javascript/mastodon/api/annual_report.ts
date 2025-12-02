import { apiRequestGet, apiRequestPost } from '../api';

export type APIAnnualReportState =
  | 'available'
  | 'generating'
  | 'eligible'
  | 'ineligible';

export const apiGetAnnualReportState = (year: number) =>
  apiRequestGet<{ state: APIAnnualReportState }>(
    `v1/annual_reports/${year}/state`,
  );

export const apiRequestGenerateAnnualReport = (year: number) =>
  apiRequestPost(`v1/annual_reports/${year}/generate`);
