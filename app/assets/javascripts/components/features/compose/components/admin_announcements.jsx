import { connect } from 'react-redux';
import PropTypes from 'prop-types';

const mapStateToProps = state => ({
  settings: state.getIn(['meta', 'admin_announcement'])
});


const AdminAnnouncements = React.createClass({
  render () {
    const { settings } = this.props;

    if (settings.length == 0) {
      return null;
    }
    return (
      <ul className='announcements'>
        <li>
          <div className='announcements__admin'>
            <p dangerouslySetInnerHTML={{__html: settings}}></p>
          </div>
        </li>
      </ul>
    );
  }
});

AdminAnnouncements.propTypes = {
  settings: PropTypes.string
};

export default connect(mapStateToProps)(AdminAnnouncements);
