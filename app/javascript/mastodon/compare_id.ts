export default function compareId (id1: string, id2: string) {
  if (id1 === id2) {
    return 0;
  }

  if (id1.length === id2.length) {
    return id1 > id2 ? 1 : -1;
  } else {
    return id1.length > id2.length ? 1 : -1;
  }
}
