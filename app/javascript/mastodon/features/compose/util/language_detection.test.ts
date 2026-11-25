import { guessLanguage } from './language_detection';

describe('guessLanguage', () => {
  test.concurrent.each([
    ['I have leftover mexican food', 'en'],
    ['hanks part 3, some nice textures', 'en'],
    ['Also, I am making a belt', 'en'],
    ['I asked Stepdad Greg ab', 'en'],
    ['Also. I am on Medicai', 'en'],
    ["So I've been passing my ", 'en'],
    [
      'δοκιμαστικό μήνυμα με πολλούς χαρακτήρες @bob@καθολική-αποδοχή-δοκιμή.ευ',
      'el',
    ],
    ['অনেকগুলো অক্ষরযুক্ত একটি পরীক্ষামূলক বার্তা @bob@সর্বজনীন-স্বীকৃতির-পরীক্ষা.ভারত', 'bn'],
    ['փորձնական հաղորդագրություն @bob@համընդհանուր-ընկալում-թեստ.հայ', 'hy'],
  ])(`"%s" = %s`, (source, language) => {
    expect(guessLanguage(source)).toBe(language);
  });
});
