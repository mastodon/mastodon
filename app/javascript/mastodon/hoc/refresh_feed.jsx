import React, { useEffect } from 'react';

const refreshFeed = (Component) => {
  const Container = (props) => {
    useEffect(() => {
      const handleKeyDown = (event) => {
        if (event.key === '.' && !event.ctrlKey && !event.shiftKey && !event.altKey && !event.metaKey) {
          event.preventDefault();
          window.scrollTo(0, 0);
        }
      };
      window.addEventListener('keydown', handleKeyDown);
      return () => {
        window.removeEventListener('keydown', handleKeyDown);
      };
    }, []);

    return <Component {...props} />;
  };

  return Container;
};

export default refreshFeed;

