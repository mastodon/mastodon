export const assignResponsesForStatus = (rootId, replies, maxLevel = 2) => {
  const idToStatus = replies
    .map(({ id }) => {
      const { in_reply_to_id, content } = replies.find(
        (item) => item.id === id,
      );
      return { id, in_reply_to_id, content, children: [] };
    })
    .reduce((prev, current) => {
      return { ...prev, [current.id]: current };
    }, {});

  Object.values(idToStatus).forEach((status) => {
    idToStatus[status.in_reply_to_id]?.children.push(status);
  });

  const filteredStatuses = Object.values(idToStatus).filter(
    (status) => status.in_reply_to_id === rootId,
  );

  const transformStatusToViewData =
    (level = 0) =>
      ({ id, children }) => {
        if (level + 2 > maxLevel) {
          return { id, children: [] };
        }
        return {
          id,
          children: children.map(transformStatusToViewData(level + 1)),
        };
      };

  return filteredStatuses.map(transformStatusToViewData());
};
