import api, { getLinks } from 'mastodon/api';

export const apiGetDomainBlocks = async (url?: string) => {
  const response = await api().request<string[]>({
    method: 'GET',
    url: url ?? '/api/v1/domain_blocks',
  });

  return {
    domains: response.data,
    links: getLinks(response),
  };
};
