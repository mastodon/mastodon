export const uniq = array => {
  return array.filter((x, i, self) => self.indexOf(x) === i)
};
