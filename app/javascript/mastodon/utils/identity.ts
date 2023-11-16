export interface ContextWithIdentity {
  identity: IdentityContext;
}

export interface IdentityContext {
  accessToken?: string;
  accountId?: string;
  disabledAccountId?: string;
  signedIn: boolean;
}
