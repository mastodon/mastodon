import type { SetOptional } from 'type-fest';

export type RequiredExcept<T, K extends keyof T> = SetOptional<Required<T>, K>;

export type AnyFunction = (...args: never) => unknown;

export function filterNulls<T>(input: T | null | undefined): input is T {
  return input !== null && input !== undefined;
}
