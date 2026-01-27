import { useCallback } from 'react';
import type { ComponentPropsWithoutRef, FC } from 'react';

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

export const Tags: FC<TagsProps> = ({ tags, active, onRemove, ...props }) => {
  if (onRemove) {
    return (
      <div className={classes.tagsWrapper}>
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
    <div className={classes.tagsWrapper}>
      {tags.map((tag) => (
        <Tag key={tag.name} active={tag.name === active} {...tag} {...props} />
      ))}
    </div>
  );
};

const MappedTag: FC<Tag & { onRemove?: (tag: string) => void }> = ({
  onRemove,
  ...props
}) => {
  const handleRemove = useCallback(() => {
    onRemove?.(props.name);
  }, [onRemove, props.name]);
  return <EditableTag {...props} onRemove={handleRemove} />;
};
