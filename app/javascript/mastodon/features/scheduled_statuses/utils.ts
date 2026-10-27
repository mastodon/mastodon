export const MINIMUM_SCHEDULE_OFFSET_MINUTES = 5;

const DEFAULT_SCHEDULE_OFFSET_MINUTES = 30;
const SCHEDULE_STEP_MINUTES = 5;

const roundUpToStep = (date: Date) => {
  const roundedDate = new Date(date);
  roundedDate.setSeconds(0, 0);

  const remainder = roundedDate.getMinutes() % SCHEDULE_STEP_MINUTES;

  if (remainder !== 0) {
    roundedDate.setMinutes(
      roundedDate.getMinutes() + (SCHEDULE_STEP_MINUTES - remainder),
    );
  }

  return roundedDate;
};

export const formatDatetimeLocal = (date: Date) => {
  const year = date.getFullYear();
  const month = String(date.getMonth() + 1).padStart(2, '0');
  const day = String(date.getDate()).padStart(2, '0');
  const hours = String(date.getHours()).padStart(2, '0');
  const minutes = String(date.getMinutes()).padStart(2, '0');

  return `${year}-${month}-${day}T${hours}:${minutes}`;
};

export const getDefaultScheduledAt = (now = new Date()) => {
  const date = new Date(now);
  date.setMinutes(date.getMinutes() + DEFAULT_SCHEDULE_OFFSET_MINUTES);

  return formatDatetimeLocal(roundUpToStep(date));
};

export const getMinimumScheduledAt = (now = new Date()) => {
  const date = new Date(now);
  date.setMinutes(date.getMinutes() + MINIMUM_SCHEDULE_OFFSET_MINUTES);

  return formatDatetimeLocal(roundUpToStep(date));
};

export const isoToDatetimeLocal = (value?: string | null) => {
  if (!value) {
    return '';
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return '';
  }

  return formatDatetimeLocal(date);
};

export const datetimeLocalToIso = (value?: string | null) => {
  if (!value) {
    return null;
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    return null;
  }

  return date.toISOString();
};

export const isScheduledAtValid = (value?: string | null, now = new Date()) => {
  if (!value) {
    return false;
  }

  const scheduledAt = new Date(value);

  if (Number.isNaN(scheduledAt.getTime())) {
    return false;
  }

  const minimumDate = new Date(now);
  minimumDate.setMinutes(
    minimumDate.getMinutes() + MINIMUM_SCHEDULE_OFFSET_MINUTES,
  );

  return scheduledAt.getTime() >= minimumDate.getTime();
};
