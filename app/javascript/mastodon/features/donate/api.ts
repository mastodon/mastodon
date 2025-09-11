import { useEffect, useState } from 'react';

import initialState from '@/mastodon/initial_state';

// TODO: Proxy this through at least an env var.
const API_URL = 'https://api.joinmastodon.org/v1/donations/campaigns/active';

export const DONATION_FREQUENCIES = ['one_time', 'monthly', 'yearly'] as const;
export type DonationFrequency = (typeof DONATION_FREQUENCIES)[number];

export const LOCALE = initialState?.meta.locale ?? 'en';

export function useDonateApi() {
  const [response, setResponse] = useState<DonateServerResponse | null>(null);

  const [seed, setSeed] = useState(0);
  useEffect(() => {
    try {
      const storedSeed = localStorage.getItem('donate_seed');
      if (storedSeed) {
        setSeed(Number.parseInt(storedSeed, 10));
        return;
      }
      const newSeed = Math.floor(Math.random() * 99) + 1;
      localStorage.setItem('donate_seed', newSeed.toString());
      setSeed(newSeed);
    } catch {
      // No local storage available, just set a seed for this session.
      setSeed(Math.floor(Math.random() * 99) + 1);
    }
  }, []);

  useEffect(() => {
    if (!seed) {
      return;
    }
    fetchCampaign({ locale: LOCALE, seed, source: 'web' })
      .then((res) => {
        setResponse(res);
      })
      .catch((reason: unknown) => {
        console.warn('Error fetching donation campaign:', reason);
      });
  }, [seed]);

  return response;
}

export interface DonateServerResponse {
  id: string;
  amounts: Record<DonationFrequency, DonateAmount>;
  donation_url: string;
  banner_message: string;
  banner_button_text: string;
  donation_message: string;
  donation_button_text: string;
  donation_success_post: string;
  default_currency: string;
}

type DonateAmount = Record<string, number[]>;

async function fetchCampaign(
  params: DonateServerRequest,
): Promise<DonateServerResponse | null> {
  // Create the URL with query parameters.
  const url = new URL(API_URL);
  for (const [key, value] of Object.entries(params)) {
    // Check to make TS happy.
    if (typeof value === 'string' || typeof value === 'number') {
      url.searchParams.append(key, value.toString());
    }
  }
  url.searchParams.append('platform', 'web');

  const response = await fetch(url);
  if (!response.ok) {
    return null;
  }
  return response.json() as Promise<DonateServerResponse>;
}

interface DonateServerRequest {
  locale: string;
  seed: number;
  source: string;
  return_url?: string;
}
