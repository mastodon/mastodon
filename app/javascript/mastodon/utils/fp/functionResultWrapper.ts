export default function functionResultWrapper<
  T extends (...args: any) => any,
  X extends (val: ReturnType<T>) => ReturnType<T>
>(fn: T) {
  return function wrapper(wrap: X) {
    return function builder(...p: Parameters<T>){
      return wrap(fn(...p as any))
    }
  };
}