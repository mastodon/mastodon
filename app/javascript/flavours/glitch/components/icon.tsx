import classNames from 'classnames';

import { ReactComponent as CheckBoxOutlineBlankIcon } from '@material-symbols/svg-600/outlined/check_box_outline_blank.svg';

interface SVGPropsWithTitle extends React.SVGProps<SVGSVGElement> {
  title?: string;
}

export type IconProp = React.FC<SVGPropsWithTitle>;

interface Props extends React.SVGProps<SVGSVGElement> {
  children?: never;
  id: string;
  icon: IconProp;
  title?: string;
}

export const Icon: React.FC<Props> = ({
  id,
  icon: IconComponent,
  className,
  title: titleProp,
  ...other
}) => {
  // eslint-disable-next-line @typescript-eslint/no-unnecessary-condition
  if (!IconComponent) {
    if (process.env.NODE_ENV !== 'production') {
      throw new Error(
        `<Icon id="${id}" className="${className}"> is missing an "icon" prop.`,
      );
    }

    IconComponent = CheckBoxOutlineBlankIcon;
  }

  const ariaHidden = titleProp ? undefined : true;
  const role = !ariaHidden ? 'img' : undefined;

  // Set the title to an empty string to remove the built-in SVG one if any
  // eslint-disable-next-line @typescript-eslint/prefer-nullish-coalescing
  const title = titleProp || '';

  return (
    <IconComponent
      className={classNames('icon', `icon-${id}`, className)}
      title={title}
      aria-hidden={ariaHidden}
      role={role}
      {...other}
    />
  );
};
