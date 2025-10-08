export const donationFrequencyTypes = [
  'one_time',
  'monthly',
  'yearly',
] as const;
export type DonationFrequency = (typeof donationFrequencyTypes)[number];

export interface DonateServerRequest {
  locale: string;
  seed: number;
}

export interface DonateServerResponse {
  id: string;
  amounts: Record<DonationFrequency, Record<string, number[]>>;
  donation_url: string;
  banner_message: string;
  banner_button_text: string;
  donation_message: string;
  donation_button_text: string;
  donation_success_post: string;
  default_currency: string;
}
