/**
 * Extend an existing type and make some of its properties required or optional.
 * @example
 * interface Person {
 * 	name: string;
 * 	age?: number;
 * 	likesIceCream?: boolean;
 * }
 *
 * type PersonWithSomeRequired = SomeRequired<Person, 'age' | 'likesIceCream' >;
 * type PersonWithSomeOptional = SomeOptional<Person, 'name' >;
 */

export type SomeRequired<T, K extends keyof T> = T & Required<Pick<T, K>>;
export type SomeOptional<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>> &
  Partial<Pick<T, K>>;
