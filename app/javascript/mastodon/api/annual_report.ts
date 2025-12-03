import api, { getAsyncRefreshHeader } from '../api';

export type APIAnnualReportState =
  | 'available'
  | 'generating'
  | 'eligible'
  | 'ineligible';

export const apiGetAnnualReportState = async (year: number) => {
  const response = await api().get<{ state: APIAnnualReportState }>(
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
