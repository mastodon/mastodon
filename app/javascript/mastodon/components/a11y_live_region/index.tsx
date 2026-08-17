import { polymorphicForwardRef } from '@/types/polymorphic';

/**
 * A live region is a content region that announces changes of its contents
 * to users of assistive technology like screen readers.
 *
 * Dynamically added warnings, errors, or live status updates should be wrapped
 * in a live region to ensure they are not missed when they appear.
 *
 * **Important:**
 * Live regions must be present in the DOM _before_
 * the to-be announced content is rendered into it.
 */

export const A11yLiveRegion = polymorphicForwardRef<'div'>(
  ({ role = 'status', as: Component = 'div', children, ...props }, ref) => {
    return (
      <Component
        role={role}
        aria-live={role === 'alert' ? 'assertive' : 'polite'}
        ref={ref}
        {...props}
      >
        {children}
      </Component>
    );
  },
);
