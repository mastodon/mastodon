//  This function returns the new value unless it is `null` or
//  `undefined`, in which case it returns the old one.
export function overwrite (oldVal, newVal) {
  return newVal === null || typeof newVal === 'undefined' ? oldVal : newVal;
}
