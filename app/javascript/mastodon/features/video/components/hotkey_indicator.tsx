import { useIntl } from 'react-intl';
import type { MessageDescriptor } from 'react-intl';

import { useTransition, animated } from '@react-spring/web';

import { Icon } from 'mastodon/components/icon';
import type { IconProp } from 'mastodon/components/icon';

export interface HotkeyEvent {
  key: number;
  icon: IconProp;
  label: MessageDescriptor;
}

export const HotkeyIndicator: React.FC<{
  events: HotkeyEvent[];
  onDismiss: (e: HotkeyEvent) => void;
}> = ({ events, onDismiss }) => {
  const intl = useIntl();

  const transitions = useTransition(events, {
    from: { opacity: 0 },
    keys: (item) => item.key,
    enter: [{ opacity: 1 }],
    leave: [{ opacity: 0 }],
    onRest: (_result, _ctrl, item) => {
      onDismiss(item);
    },
  });

  return (
    <>
      {transitions((style, item) => (
        <animated.div className='video-player__hotkey-indicator' style={style}>
          <Icon id='' icon={item.icon} />
          <span className='video-player__hotkey-indicator__label'>
            {intl.formatMessage(item.label)}
          </span>
        </animated.div>
      ))}
    </>
  );
};
