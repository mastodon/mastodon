import classNames from 'classnames';

/**
 * Wrapper for displaying a number of Avatar components horizontally,
 * either spaced out (default) or overlapping (using the `compact` prop).
 */

export const AvatarGroup: React.FC<{
  compact?: boolean;
  children: React.ReactNode;
}> = ({ children, compact = false }) => (
  <div
    className={classNames('avatar-group', { 'avatar-group--compact': compact })}
  >
    {children}
  </div>
);
