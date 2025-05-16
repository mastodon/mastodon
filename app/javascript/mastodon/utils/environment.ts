export function isDevelopment() {
  if (typeof process !== 'undefined')
    return process.env.NODE_ENV === 'development';
  else return import.meta.env.DEV;
}

export function isProduction() {
  if (typeof process !== 'undefined')
    return process.env.NODE_ENV === 'production';
  else return import.meta.env.PROD;
}
