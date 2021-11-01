import { getLinesForResponses } from '../utils/setLinesForResponses';

describe('setLinesForResponses', () => {
  it('returns lines levels [] if need only one line level', () => {
    expect(
      getLinesForResponses([{ id: 2, children: [{ id: 3, children: [] }] }]),
    ).toStrictEqual({
      2: { mode: 'o', level: 1, hiddenLevels: 0, lastChild: true },
      3: { mode: 'i', level: 2, hiddenLevels: 0, lastChild: true },
    });
  });

  it('returns types of lines', () => {
    expect(
      getLinesForResponses([
        {
          id: 2,
          children: [
            { id: 3, children: [] },
            { id: 4, children: [{ id: 5, children: [] }] },
          ],
        },
        { id: 6, children: [] },
        { id: 7, children: [{ id: 8, children: [{ id: 9, children: [] }] }] },
      ]),
    ).toStrictEqual({
      2: { mode: 'o', lastChild: false, level: 1, hiddenLevels: 0 },
      3: { mode: 'i', lastChild: false, level: 2, hiddenLevels: 0 },
      4: { mode: 'io', lastChild: true, level: 2, hiddenLevels: 0 },
      5: { mode: 'i', lastChild: true, level: 3, hiddenLevels: 1 },
      6: { mode: '', lastChild: false, level: 1, hiddenLevels: 0 },
      7: { mode: 'o', lastChild: true, level: 1, hiddenLevels: 0 },
      8: { mode: 'io', lastChild: true, level: 2, hiddenLevels: 0 },
      9: { mode: 'i', lastChild: true, level: 3, hiddenLevels: 1 },
    });
  });
});
