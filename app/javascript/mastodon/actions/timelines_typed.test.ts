import { Map as ImmutableMap, List as ImmutableList } from 'immutable';

import { accountTimelineAcceptsStatus, timelineKey } from './timelines_typed';
import type { AccountTimelineParams } from './timelines_typed';

/** Minimal status shape used by compose / account timeline insertion. */
interface StatusLike {
  id: string;
  account: { id: string };
  visibility: string;
  in_reply_to_id: string | null;
  reblog: unknown;
  media_attachments: unknown[];
  tags?: { name: string }[];
}

const baseStatus = (overrides: Partial<StatusLike> = {}): StatusLike => ({
  id: 'status-1',
  account: { id: '42' },
  visibility: 'public',
  in_reply_to_id: null,
  reblog: null,
  media_attachments: [],
  tags: [],
  ...overrides,
});

const defaultParams = (
  overrides: Partial<AccountTimelineParams> = {},
): AccountTimelineParams => ({
  type: 'account',
  userId: '42',
  boosts: false,
  replies: false,
  media: false,
  pinned: false,
  ...overrides,
});

describe('account timeline key format (profile vs compose regression)', () => {
  // Regression for #39625: profile uses timelineKey(); compose used to insert
  // into the legacy `account:${id}` key, so new posts never appeared without refresh.
  test('profile page key is not the legacy account:${id} key', () => {
    const accountId = '42';
    const profileKey = timelineKey({ type: 'account', userId: accountId });
    const legacyComposeKey = `account:${accountId}`;

    expect(profileKey).toBe('account:42:0000');
    expect(legacyComposeKey).not.toBe(profileKey);
  });

  test('inserting only into legacy key would miss the loaded profile timeline', () => {
    const accountId = '42';
    const profileKey = timelineKey({ type: 'account', userId: accountId });
    const legacyComposeKey = `account:${accountId}`;

    const timelines = ImmutableMap({
      [profileKey]: ImmutableMap({
        items: ImmutableList(['existing-status']),
        online: false,
      }),
    });

    // What compose used to do: look up the legacy key only.
    const legacyTimeline = timelines.get(legacyComposeKey);
    // Profile timeline is loaded, but under the new key — so optimistic insert missed it.
    expect(legacyTimeline).toBeUndefined();
    const profileItems = timelines.get(profileKey)?.get('items');
    expect(ImmutableList.isList(profileItems) && profileItems.size).toBe(1);
  });
});

describe('accountTimelineAcceptsStatus', () => {
  test('accepts a top-level public post on the default posts timeline', () => {
    expect(accountTimelineAcceptsStatus(defaultParams(), baseStatus())).toBe(
      true,
    );
  });

  test('rejects direct messages', () => {
    expect(
      accountTimelineAcceptsStatus(
        defaultParams(),
        baseStatus({ visibility: 'direct' }),
      ),
    ).toBe(false);
  });

  test('accepts unlisted and private posts on own profile timelines', () => {
    expect(
      accountTimelineAcceptsStatus(
        defaultParams(),
        baseStatus({ visibility: 'unlisted' }),
      ),
    ).toBe(true);
    expect(
      accountTimelineAcceptsStatus(
        defaultParams(),
        baseStatus({ visibility: 'private' }),
      ),
    ).toBe(true);
  });

  test('rejects replies unless the replies filter is on', () => {
    const reply = baseStatus({ in_reply_to_id: 'parent-1' });
    expect(accountTimelineAcceptsStatus(defaultParams(), reply)).toBe(false);
    expect(
      accountTimelineAcceptsStatus(defaultParams({ replies: true }), reply),
    ).toBe(true);
  });

  test('rejects boosts unless the boosts filter is on', () => {
    const boost = baseStatus({ reblog: { id: 'original' } });
    expect(accountTimelineAcceptsStatus(defaultParams(), boost)).toBe(false);
    expect(
      accountTimelineAcceptsStatus(defaultParams({ boosts: true }), boost),
    ).toBe(true);
  });

  test('rejects media-only timelines when the status has no media', () => {
    expect(
      accountTimelineAcceptsStatus(
        defaultParams({ media: true }),
        baseStatus(),
      ),
    ).toBe(false);
    expect(
      accountTimelineAcceptsStatus(
        defaultParams({ media: true }),
        baseStatus({ media_attachments: [{ id: 'm1' }] }),
      ),
    ).toBe(true);
  });

  test('rejects tagged timelines when the status lacks that tag', () => {
    expect(
      accountTimelineAcceptsStatus(
        defaultParams({ tagged: 'nature' }),
        baseStatus({ tags: [{ name: 'art' }] }),
      ),
    ).toBe(false);
    expect(
      accountTimelineAcceptsStatus(
        defaultParams({ tagged: 'nature' }),
        baseStatus({ tags: [{ name: 'nature' }] }),
      ),
    ).toBe(true);
  });

  test('never accepts pinned timelines (pins are managed separately)', () => {
    expect(
      accountTimelineAcceptsStatus(
        defaultParams({ pinned: true }),
        baseStatus(),
      ),
    ).toBe(false);
  });

  test('rejects timelines for a different account', () => {
    expect(
      accountTimelineAcceptsStatus(
        defaultParams({ userId: '99' }),
        baseStatus({ account: { id: '42' } }),
      ),
    ).toBe(false);
  });
});
