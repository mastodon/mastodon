import { forwardRef, useCallback } from 'react';
import type { ComponentPropsWithoutRef, FC } from 'react';

import classNames from 'classnames';

import classes from './style.module.css';
import { EditableTag, Tag } from './tag';
import type { TagProps } from './tag';

type Tag = TagProps & { name: string };

export type TagsProps = {
  tags: Tag[];
  active?: string;
} & (
  | ({
      onRemove?: never;
    } & ComponentPropsWithoutRef<'button'>)
  | ({ onRemove?: (tag: string) => void } & ComponentPropsWithoutRef<'span'>)
);

export const Tags = forwardRef<HTMLDivElement, TagsProps>(
  ({ tags, active, onRemove, className, ...props }, ref) => {
    if (onRemove) {
      return (
        <div className={classNames(classes.tagsWrapper, className)}>
          {tags.map((tag) => (
            <MappedTag
              key={tag.name}
              active={tag.name === active}
              onRemove={onRemove}
              {...tag}
              {...props}
            />
          ))}
        </div>
      );
    }

    return (
      <div className={classNames(classes.tagsWrapper, className)} ref={ref}>
        {tags.map((tag) => (
          <Tag
            key={tag.name}
            active={tag.name === active}
            {...tag}
            {...props}
          />
        ))}
      </div>
    );
  },
);
Tags.displayName = 'Tags';

const MappedTag: FC<Tag & { onRemove?: (tag: string) => void }> = ({
  onRemove,
  ...props
}) => {
  const handleRemove = useCallback(() => {
    onRemove?.(props.name);
  }, [onRemove, props.name]);
  return <EditableTag {...props} onRemove={handleRemove} />;
};
