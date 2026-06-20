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

export type DeepPartial<T> = T extends object
  ? {
      [K in keyof T]?: DeepPartial<T[K]>;
    }
  : T;

export type SomeRequired<T, K extends keyof T> = T & Required<Pick<T, K>>;
export type SomeOptional<T, K extends keyof T> = Pick<T, Exclude<keyof T, K>> &
  Partial<Pick<T, K>>;

export type RequiredExcept<T, K extends keyof T> = SomeOptional<Required<T>, K>;

export type OmitValueType<T, V> = {
  [K in keyof T as T[K] extends V ? never : K]: T[K];
};

export type OmitUnion<TUnion, TBase> = TBase & Omit<TUnion, keyof TBase>;

export type PickValueType<T, V> = {
  [K in keyof T as T[K] extends V | undefined ? K : never]: T[K];
};

export type AnyFunction = (...args: never) => unknown;

export type SnakeToCamelCase<S extends string> =
  S extends `${infer T}_${infer U}`
    ? `${T}${Capitalize<SnakeToCamelCase<U>>}`
    : S;
