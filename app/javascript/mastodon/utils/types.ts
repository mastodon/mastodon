import type { SetOptional } from 'type-fest';

export type RequiredExcept<T, K extends keyof T> = SetOptional<Required<T>, K>;

export type AnyFunction = (...args: never) => unknown;
