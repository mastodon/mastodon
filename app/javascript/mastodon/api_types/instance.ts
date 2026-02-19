export interface ApiTermsOfServiceJSON {
  effective_date: string;
  effective: boolean;
  succeeded_by: string | null;
  content: string;
}

export interface ApiPrivacyPolicyJSON {
  updated_at: string;
  content: string;
}
