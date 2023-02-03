//  This function binds the given `handlers` to the `target`.
export function assignHandlers (target, handlers) {
  if (!target || !handlers) {
    return;
  }

  //  We just bind each handler to the `target`.
  const handle = target.handlers = {};
  Object.keys(handlers).forEach(
    key => handle[key] = handlers[key].bind(target),
  );
}

//  This function only returns the component if the result of calling
//  `test` with `data` is `true`.  Useful with funciton binding.
export function conditionalRender (test, data, component) {
  return test(data) ? component : null;
}

//  This object provides props to make the component not visible.
export const hiddenComponent = { style: { display: 'none' } };
