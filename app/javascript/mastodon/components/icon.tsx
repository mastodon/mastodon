import classNames from 'classnames';

import CheckBoxOutlineBlankIcon from '@/material-icons/400-24px/check_box_outline_blank.svg?react';
import { isProduction } from 'mastodon/utils/environment';

interface SVGPropsWithTitle extends React.SVGProps<SVGSVGElement> {
  title?: string;
}

export type IconProp = React.FC<SVGPropsWithTitle>;

interface Props extends React.SVGProps<SVGSVGElement> {
  children?: never;
  id: string;
  icon: IconProp;
  noFill?: boolean;
}

export const Icon: React.FC<Props> = ({
  id,
  icon: IconComponent,
  className,
  'aria-label': ariaLabel,
  noFill = false,
  ...other
}) => {
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (!IconComponent) {
    if (!isProduction()) {
      throw new Error(
        `<Icon id="${id}" className="${className}"> is missing an "icon" prop.`,
      );
    }

    IconComponent = CheckBoxOutlineBlankIcon;
  }

  const ariaHidden = ariaLabel ? undefined : true;
  const role = !ariaHidden ? 'img' : undefined;

  // Set the title to an empty string to remove the built-in SVG one if any
  // eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
  const title = ariaLabel || '';

  return (
    <IconComponent
      className={classNames(
        'icon',
        `icon-${id}`,
        noFill && 'icon--no-fill',
        className,
      )}
      title={title}
      aria-hidden={ariaHidden}
      aria-label={ariaLabel}
      role={role}
      {...other}
    />
  );
};
