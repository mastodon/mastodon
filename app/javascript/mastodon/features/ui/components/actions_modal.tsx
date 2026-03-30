import classNames from 'classnames';
import { Link } from 'react-router-dom';

import { DropdownMenuItemContent } from 'mastodon/components/dropdown_menu';
import type { MenuItem } from 'mastodon/models/dropdown_menu';
import {
  isActionItem,
  isExternalLinkItem,
} from 'mastodon/models/dropdown_menu';

export const ActionsModal: React.FC<{
  actions: MenuItem[];
  onClick: React.MouseEventHandler;
  className?: string;
}> = ({ actions, onClick, className }) => (
  <div className={classNames('modal-root__modal actions-modal', className)}>
    <ul>
      {actions.map((option, i: number) => {
        if (option === null) {
          return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
        }

        const { text, highlighted, disabled, dangerous } = option;

        let element: React.ReactElement;

        if (isActionItem(option)) {
          element = (
            <button
              onClick={onClick}
              data-index={i}
              disabled={disabled}
              type='button'
            >
              <DropdownMenuItemContent item={option} />
            </button>
          );
        } else if (isExternalLinkItem(option)) {
          element = (
            <a
              href={option.href}
              target={option.target ?? '_target'}
              data-method={option.method}
              rel='noopener'
              onClick={onClick}
              data-index={i}
            >
              <DropdownMenuItemContent item={option} />
            </a>
          );
        } else {
          element = (
            <Link to={option.to} onClick={onClick} data-index={i}>
              <DropdownMenuItemContent item={option} />
            </Link>
          );
        }

        return (
          <li
            className={classNames('dropdown-menu__item', {
              'dropdown-menu__item--dangerous': dangerous,
              'dropdown-menu__item--highlighted': highlighted,
            })}
            key={`${text}-${i}`}
          >
            {element}
          </li>
        );
      })}
    </ul>
  </div>
);
