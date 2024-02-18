import PropTypes from 'prop-types';

import classNames from 'classnames';

import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';

import { IconButton } from '../../../components/icon_button';

export default class ActionsModal extends ImmutablePureComponent {

  static propTypes = {
    status: ImmutablePropTypes.map,
    onClick: PropTypes.func,
    actions: PropTypes.arrayOf(PropTypes.shape({
      active: PropTypes.bool,
      href: PropTypes.string,
      icon: PropTypes.string,
      meta: PropTypes.string,
      name: PropTypes.string,
      text: PropTypes.string,
    })),
    renderItemContents: PropTypes.func,
  };

  renderAction = (action, i) => {
    if (action === null) {
      return <li key={`sep-${i}`} className='dropdown-menu__separator' />;
    }

    const { icon = null, iconComponent = null, text, meta = null, active = false, href = '#' } = action;
    let contents = this.props.renderItemContents && this.props.renderItemContents(action, i);

    if (!contents) {
      contents = (
        <>
          {icon && <IconButton title={text} icon={icon} iconComponent={iconComponent} role='presentation' tabIndex={-1} inverted />}
          <div>
            <div className={classNames({ 'actions-modal__item-label': !!meta })}>{text}</div>
            <div>{meta}</div>
          </div>
        </>
      );
    }

    return (
      <li key={`${text}-${i}`}>
        <a href={href} target='_blank' rel='noopener noreferrer' onClick={this.props.onClick} data-index={i} className={classNames('link', { active })}>
          {contents}
        </a>
      </li>
    );
  };

  render () {
    return (
      <div className='modal-root__modal actions-modal'>
        <ul>
          {this.props.actions.map(this.renderAction)}
        </ul>
      </div>
    );
  }

}
