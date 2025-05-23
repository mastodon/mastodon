import classNames from 'classnames';

/**
 * Wrapper for displaying a number of Avatar components horizontally,
 * either spaced out (default) or overlapping (using the `compact` prop).
 */

export const AvatarGroup: React.FC<{
  compact?: boolean;
  avatarHeight?: number;
  children: React.ReactNode;
}> = ({ children, compact = false, avatarHeight }) => (
  <div
    className={classNames('avatar-group', { 'avatar-group--compact': compact })}
    style={
      avatarHeight
        ? ({ '--avatar-height': `${avatarHeight}px` } as React.CSSProperties)
        : undefined
    }
  >
    {children}
  </div>
);
