const pad = (value: number) => value.toString().padStart(2, '0');

export const isoStringToDateTimeLocal = (value?: string | null) => {
  if (!value) {
    return '';
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return '';
  }

  return `${date.getFullYear()}-${pad(date.getMonth() + 1)}-${pad(date.getDate())}T${pad(date.getHours())}:${pad(date.getMinutes())}`;
};

export const dateTimeLocalToISOString = (value?: string | null) => {
  if (!value) {
    return null;
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return date.toISOString();
};

export const minScheduledDateTimeLocal = (from = new Date()) => {
  const date = new Date(from.getTime() + 5 * 60 * 1000);

  return isoStringToDateTimeLocal(date.toISOString());
};
