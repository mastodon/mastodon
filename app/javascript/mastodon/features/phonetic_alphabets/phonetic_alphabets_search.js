const phoneticAlphabets = require('./phonetic_code_map.json');

function search(value) {
  if (!phoneticAlphabets[value]) {
    return [];
  }
  return phoneticAlphabets[value].map(x => `/${x}/`);
}

export { search };
