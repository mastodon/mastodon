import React from 'react';
import { connect } from 'react-redux';
import PropTypes from 'prop-types';

const mapStateToProps = state => ({
  settings: state.getIn(['meta', 'admin_announcement']),
});


class AdminAnnouncements extends React.PureComponent {

  static propTypes = {
    settings: PropTypes.string,
  };

  render () {
    const { settings } = this.props;

    if (settings.length === 0) {
      return null;
    }
    return (
      <ul className='announcements'>
        <li>
          <div className='announcements__admin'>
            <p dangerouslySetInnerHTML={{__html: settings}} />
          </div>
        </li>
      </ul>
    );
  }

}

export default connect(mapStateToProps)(AdminAnnouncements);
