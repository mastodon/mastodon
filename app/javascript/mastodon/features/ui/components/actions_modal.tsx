import classNames from 'classnames';
import { Link } from 'react-router-dom';

import type { MenuItem } from 'mastodon/models/dropdown_menu';
import {
  isActionItem,
  isExternalLinkItem,
} from 'mastodon/models/dropdown_menu';

export const ActionsModal: React.FC<{
  actions: MenuItem[];
  onClick: React.MouseEventHandler;
}> = ({ actions, onClick }) => (
  <div className='modal-root__modal actions-modal'>
    <ul>
      {actions.map((option, i: number) => {
        if (option === null) {
          return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
        }

        const { text, dangerous } = option;

        let element: React.ReactElement;

        if (isActionItem(option)) {
          element = (
            <button onClick={onClick} data-index={i}>
              {text}
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
              {text}
            </a>
          );
        } else {
          element = (
            <Link to={option.to} onClick={onClick} data-index={i}>
              {text}
            </Link>
          );
        }

        return (
          <li
            className={classNames({
              'dropdown-menu__item--dangerous': dangerous,
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
