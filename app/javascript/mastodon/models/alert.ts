import type { MessageDescriptor } from 'react-intl';

export type TranslatableString = string | MessageDescriptor;

export type TranslatableValues = Record<string, string | number | Date>;

export interface Alert {
  key: number;
  title?: TranslatableString;
  message: TranslatableString;
  action?: TranslatableString;
  values?: TranslatableValues;
  onClick?: () => void;
}
