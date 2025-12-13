import { useCallback, useEffect } from 'react';

import { FormattedMessage } from 'react-intl';

import { animated, config, useSpring } from '@react-spring/web';

interface UploadAreaProps {
  active?: boolean;
  onClose: () => void;
}

export const UploadArea: React.FC<UploadAreaProps> = ({ active, onClose }) => {
  const handleKeyUp = useCallback(
    (e: KeyboardEvent) => {
      if (active && e.key === 'Escape') {
        e.preventDefault();
        e.stopPropagation();
        onClose();
      }
    },
    [active, onClose],
  );

  useEffect(() => {
    window.addEventListener('keyup', handleKeyUp, false);

    return () => {
      window.removeEventListener('keyup', handleKeyUp);
    };
  }, [handleKeyUp]);

  const wrapperAnimStyles = useSpring({
    from: {
      opacity: 0,
    },
    to: {
      opacity: 1,
    },
    reverse: !active,
  });
  const backgroundAnimStyles = useSpring({
    from: {
      transform: 'scale(0.95)',
    },
    to: {
      transform: 'scale(1)',
    },
    reverse: !active,
    config: config.wobbly,
  });

  return (
    <animated.div
      className='upload-area'
      style={{
        ...wrapperAnimStyles,
        visibility: active ? 'visible' : 'hidden',
      }}
    >
      <div className='upload-area__drop'>
        <animated.div
          className='upload-area__background'
          style={backgroundAnimStyles}
        />
        <div className='upload-area__content'>
          <FormattedMessage
            id='upload_area.title'
            defaultMessage='Drag & drop to upload'
          />
        </div>
      </div>
    </animated.div>
  );
};
