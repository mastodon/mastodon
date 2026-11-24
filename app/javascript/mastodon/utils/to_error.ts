export const toError = (err: unknown): Error => {
  if (err instanceof Error) {
    return err;
  }

  if (typeof err === 'string') {
    return new Error(err);
  }

  if (typeof err === 'object' && err !== null) {
    return new Error(JSON.stringify(err));
  }

  return new Error('Unknown error occurred');
};
