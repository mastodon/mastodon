//  Package imports.
import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

//  Our imports
import { changeLocalSetting } from 'flavours/glitch/actions/local_settings';
import { closeModal } from 'flavours/glitch/actions/modal';

import LocalSettingsNavigation from './navigation';
import LocalSettingsPage from './page';

const mapStateToProps = state => ({
  settings: state.get('local_settings'),
});

const mapDispatchToProps = dispatch => ({
  onChange (setting, value) {
    dispatch(changeLocalSetting(setting, value));
  },
  onClose () {
    dispatch(closeModal());
  },
});

class LocalSettings extends PureComponent {

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

export default connect(mapStateToProps, mapDispatchToProps)(LocalSettings);
