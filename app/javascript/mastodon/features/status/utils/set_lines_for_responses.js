const getSetter = () => ({
  value: false,
  blocked: false,
  not() {
    this.blocked = true;
    this.value = false;
  },
  can() {
    if (this.blocked === false) this.value = true;
  },
});

const flatChildren = (list, level = 1, hiddenLevels = 0, lastChildX = undefined) => {
  return list
    .map(({ id, children }, index, array) => {
      const getMode = () => {
        const canOut = getSetter();
        const canIn = getSetter();

        if (children.length > 0) {
          canOut.can();
        }

        if (level > 1) {
          canIn.can();
        }

        if (canIn.value && canOut.value) {
          return 'io';
        }
        if (canIn.value) {
          return 'i';
        }

        if (canOut.value) {
          return 'o';
        }

        return '';
      };

      const current = {
        mode: getMode(),
        level,
        hiddenLevels,
        lastChild: array[index + 1] !== undefined ? false : true,
        firstChild: index === 0 ? true : false,
      };

      return children.length
        ? [
          { [id]: current },
          ...flatChildren(
            children,
            level + 1,
            current.lastChild === true && level > 1 ? hiddenLevels + 1 : hiddenLevels,
            current.lastChild || lastChildX,
          ),
        ]
        : [{ [id]: current }];
    })
    .flat();
};

export function getLinesForResponses(responses) {
  return flatChildren(responses).reduce((all, item) => {
    return { ...all, [Object.keys(item)[0]]: Object.values(item)[0] };
  }, {});
}

export const setResponsesWithLinesData = (responses) => {
  const linesData = getLinesForResponses(responses);

  return responses.map(addLinesToResponses(linesData));
};

const addLinesToResponses = (linesData) => (response) => {
  return {
    ...response,
    lines: linesData[response.id],
    children: response.children.map(addLinesToResponses(linesData)),
  };
};
