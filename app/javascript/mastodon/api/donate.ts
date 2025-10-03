import type {
  DonateServerRequest,
  DonateServerResponse,
} from '../api_types/donate';

// TODO: Proxy this through the backend.
const API_URL = 'https://api.joinmastodon.org/v1/donations/campaigns/active';

export const apiGetDonateData = async ({
  locale,
  seed,
}: DonateServerRequest) => {
  // Create the URL with query parameters.
  const params = new URLSearchParams({
    locale,
    seed: seed.toString(),
    platform: 'web',
    source: 'menu',
  });
  const url = new URL(`${API_URL}?${params.toString()}`);

  const response = await fetch(url);
  if (!response.ok) {
    throw new Error(`Error fetching donation campaign: ${response.statusText}`);
  }
  if (response.status === 204) {
    return null;
  }
  return response.json() as Promise<DonateServerResponse>;
};
