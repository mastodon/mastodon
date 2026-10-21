import { guessLanguage } from './language_detection';

describe('guessLanguage', () => {
  test('guesses from a greek domain', () => {
    expect(guessLanguage('@bob@καθολική-αποδοχή-δοκιμή.ευ')).toBe('el');
  });

  test('guesses from a bengali domain', () => {
    expect(guessLanguage('@bob@সর্বজনীন-স্বীকৃতির-পরীক্ষা.ভারত')).toBe('bn');
  });

  test('guesses from a armenian domain', () => {
    expect(guessLanguage('@bob@համընդհանուր-ընկալում-թեստ.հայ')).toBe('hy');
  });

  test('guesses from a bulgarian domain', () => {
    expect(guessLanguage('@bob@универсальное-принятие-тест.москва')).toBe('bg');
  });
});
