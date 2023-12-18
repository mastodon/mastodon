import { createAction } from '@reduxjs/toolkit';

import type { Account } from 'flavours/glitch/models/account';

export const blockDomainSuccess = createAction<{
  domain: string;
  accounts: Account[];
}>('domain_blocks/block/SUCCESS');

export const unblockDomainSuccess = createAction<{
  domain: string;
  accounts: Account[];
}>('domain_blocks/unblock/SUCCESS');
