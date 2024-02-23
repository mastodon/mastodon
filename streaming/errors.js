// @ts-check

/**
 * Typed as a string because otherwise it's a const string, which means we can't
 * override it in let statements.
 * @type {string}
 */
const UNEXPECTED_ERROR_MESSAGE = 'An unexpected error occurred';
exports.UNKNOWN_ERROR_MESSAGE = UNEXPECTED_ERROR_MESSAGE;

/**
 * Extracts the status and message properties from the error object, if
 * available for public use. The `unknown` is for catch statements
 * @param {Error | AuthenticationError | RequestError | unknown} err
 */
exports.extractStatusAndMessage = function(err) {
  let statusCode = 500;
  let errorMessage = UNEXPECTED_ERROR_MESSAGE;
  if (err instanceof AuthenticationError || err instanceof RequestError) {
    statusCode = err.status;
    errorMessage = err.message;
  }

  return { statusCode, errorMessage };
};

class RequestError extends Error {
  /**
   * @param {string} message
   */
  constructor(message) {
    super(message);
    this.name = "RequestError";
    this.status = 400;
  }
}

exports.RequestError = RequestError;

class AuthenticationError extends Error {
  /**
   * @param {string} message
   */
  constructor(message) {
    super(message);
    this.name = "AuthenticationError";
    this.status = 401;
  }
}

exports.AuthenticationError = AuthenticationError;
