exports.format = (msgs) => {
  const results = {};
  for (const [id, msg] of Object.entries(msgs)) {
    results[id] = msg.defaultMessage;
  }
  return results;
};
