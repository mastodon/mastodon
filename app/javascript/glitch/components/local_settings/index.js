//  Package imports
import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Our imports
import LocalSettingsPage from './page';
import LocalSettingsNavigation from './navigation';

//  Stylesheet imports
import './style.scss';

export default class LocalSettings extends React.PureComponent {

  static propTypes = {
    onChange: PropTypes.func.isRequired,
    onClose: PropTypes.func.isRequired,
    settings: ImmutablePropTypes.map.isRequired,
  };

  state = {
    currentIndex: 0,
  };

  navigateTo = (index) =>
    this.setState({ currentIndex: +index });

  render () {

    const { navigateTo } = this;
    const { onChange, onClose, settings } = this.props;
    const { currentIndex } = this.state;

    return (
      <div className='glitch modal-root__modal local-settings'>
        <LocalSettingsNavigation
          index={currentIndex}
          onClose={onClose}
          onNavigate={navigateTo}
        />
        <LocalSettingsPage
          index={currentIndex}
          onChange={onChange}
          settings={settings}
        />
      </div>
    );
  }

}
