import { http, HttpResponse } from 'msw';
import { action } from 'storybook/actions';

import { relationshipsFactory } from './factories';

export const mockHandlers = {
  mute: http.post<{ id: string }>('/api/v1/accounts/:id/mute', ({ params }) => {
    action('muting account')(params);
    return HttpResponse.json(
      relationshipsFactory({ id: params.id, muting: true }),
    );
  }),
  unmute: http.post<{ id: string }>(
    '/api/v1/accounts/:id/unmute',
    ({ params }) => {
      action('unmuting account')(params);
      return HttpResponse.json(
        relationshipsFactory({ id: params.id, muting: false }),
      );
    },
  ),
  block: http.post<{ id: string }>(
    '/api/v1/accounts/:id/block',
    ({ params }) => {
      action('blocking account')(params);
      return HttpResponse.json(
        relationshipsFactory({ id: params.id, blocking: true }),
      );
    },
  ),
  unblock: http.post<{ id: string }>(
    '/api/v1/accounts/:id/unblock',
    ({ params }) => {
      action('unblocking account')(params);
      return HttpResponse.json(
        relationshipsFactory({
          id: params.id,
          blocking: false,
        }),
      );
    },
  ),
};

export const unhandledRequestHandler = ({ url }: Request) => {
  const { pathname } = new URL(url);
  if (pathname.startsWith('/api/v1/')) {
    action(`unhandled request to ${pathname}`)(url);
    console.warn(
      `Unhandled request to ${pathname}. Please add a handler for this request in your storybook configuration.`,
    );
  }
};
