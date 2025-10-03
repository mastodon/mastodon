const CODA_MARKER = '$$'; // marks the end of the string

interface Dict {
  [key: string]: Dict;
}

export class Trie {
  #dict: Dict;

  constructor(words: string[]) {
    this.#dict = {};
    for (const word of words) {
      let dict = this.#dict;
      for (let j = 0, len2 = word.length; j < len2; j++) {
        const char = word.charAt(j);
        dict = dict[char] ??= {};
      }
      dict[CODA_MARKER] = {};
    }
  }

  search(str: string): string | undefined {
    let i = -1;
    const len = str.length;
    const stack = [this.#dict];
    while (++i < len) {
      const dict = stack[i];
      const char = str.charAt(i);
      const next = dict?.[char];
      if (next) {
        stack.push(next);
      } else {
        break;
      }
    }
    while (stack.length) {
      if (stack.pop()?.[CODA_MARKER]) {
        return str.slice(0, stack.length);
      }
    }
    return undefined;
  }
}
