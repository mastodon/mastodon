import { assignResponsesForStatus } from '../utils/assignResponesForStatus';

describe('assignResponsesForStatus', () => {
  it('returns [] when no statuses', () => {
    const rootId = 1;
    const statuses = [];
    expect(assignResponsesForStatus(rootId, statuses)).toStrictEqual([]);
  });

  it('returns the responses of the root', () => {
    const rootId = 1;
    const statuses = [{ id: 2, in_reply_to_id: 1 }];

    expect(assignResponsesForStatus(rootId, statuses)).toStrictEqual([
      { id: 2, children: [] },
    ]);
  });

  it('returns 2 levels of responses', () => {
    const rootId = 1;
    const statuses = [
      { id: 2, in_reply_to_id: 1 },
      { id: 3, in_reply_to_id: 2 },
      { id: 4, in_reply_to_id: 3 },
    ];

    expect(assignResponsesForStatus(rootId, statuses, 2)).toStrictEqual([
      { id: 2, children: [{ id: 3, children: [] }] },
    ]);
  });
});
