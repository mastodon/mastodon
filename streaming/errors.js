// @ts-check

/**
 * Typed as a string because otherwise it's a const string, which means we can't
 * override it in let statements.
 * @type {string}
 */
export const UNEXPECTED_ERROR_MESSAGE = 'An unexpected error occurred';

/**
 * Extracts the status and message properties from the error object, if
 * available for public use. The `unknown` is for catch statements
 * @param {Error | AuthenticationError | RequestError | unknown} err
 */
export function extractStatusAndMessage(err) {
  let statusCode = 500;
  let errorMessage = UNEXPECTED_ERROR_MESSAGE;
  if (err instanceof AuthenticationError || err instanceof RequestError) {
    statusCode = err.status;
    errorMessage = err.message;
  }

  return { statusCode, errorMessage };
}

export class RequestError extends Error {
  /**
   * @param {string} message
   */
  constructor(message) {
    super(message);
    this.name = "RequestError";
    this.status = 400;
  }
}

export class AuthenticationError extends Error {
  /**
   * @param {string} message
   */
  constructor(message) {
    super(message);
    this.name = "AuthenticationError";
    this.status = 401;
  }
}
