import { guessLanguage } from './language_detection';

describe('guessLanguage', () => {
  test('guesses from a greek domain', () => {
    expect(
      guessLanguage(
        'δοκιμαστικό μήνυμα με πολλούς χαρακτήρες @bob@καθολική-αποδοχή-δοκιμή.ευ',
      ),
    ).toBe('el');
  });

  test('guesses from a bengali domain', () => {
    expect(
      guessLanguage(
        'অনেকগুলো অক্ষরযুক্ত একটি পরীক্ষামূলক বার্তা @bob@সর্বজনীন-স্বীকৃতির-পরীক্ষা.ভারত',
      ),
    ).toBe('bn');
  });

  test('guesses from a armenian domain', () => {
    expect(
      guessLanguage(
        'փորձնական հաղորդագրություն @bob@համընդհանուր-ընկալում-թեստ.հայ',
      ),
    ).toBe('hy');
  });
});
