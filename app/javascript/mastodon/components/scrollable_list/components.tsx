import type { ComponentPropsWithoutRef } from 'react';
import { Children, forwardRef } from 'react';

import classNames from 'classnames';

import { LoadingIndicator } from '../loading_indicator';

export const Scrollable = forwardRef<
  HTMLDivElement,
  ComponentPropsWithoutRef<'div'> & {
    flex?: boolean;
    fullscreen?: boolean;
  }
>(({ flex = true, fullscreen, className, children, ...otherProps }, ref) => {
  return (
    <div
      className={classNames(
        'scrollable',
        { 'scrollable--flex': flex, fullscreen },
        className,
      )}
      ref={ref}
      {...otherProps}
    >
      {children}
    </div>
  );
});

Scrollable.displayName = 'Scrollable';

export const ItemList = forwardRef<
  HTMLDivElement,
  ComponentPropsWithoutRef<'div'> & {
    isLoading?: boolean;
    emptyMessage?: React.ReactNode;
  }
>(({ isLoading, emptyMessage, className, children, ...otherProps }, ref) => {
  if (!isLoading && Children.count(children) === 0 && emptyMessage) {
    return (
      <div className='empty-column-indicator'>
        <span>{emptyMessage}</span>
      </div>
    );
  }

  return (
    <>
      <div
        role='feed'
        className={classNames('item-list', className)}
        ref={ref}
        {...otherProps}
      >
        {!isLoading && children}
      </div>
      {isLoading && (
        <div className='scrollable__append'>
          <LoadingIndicator />
        </div>
      )}
    </>
  );
});

ItemList.displayName = 'ItemList';

export const Article = forwardRef<
  HTMLElement,
  ComponentPropsWithoutRef<'article'> & {
    focusable?: boolean;
    'data-id'?: string;
    'aria-posinset': number;
    'aria-setsize': number;
  }
>(({ focusable, className, children, ...otherProps }, ref) => {
  return (
    <article
      ref={ref}
      className={classNames(className, { focusable })}
      tabIndex={-1}
      {...otherProps}
    >
      {children}
    </article>
  );
});

Article.displayName = 'Article';
