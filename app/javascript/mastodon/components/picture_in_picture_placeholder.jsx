import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { removePictureInPicture } from 'mastodon/actions/picture_in_picture';
import { Icon }  from 'mastodon/components/icon';

class PictureInPicturePlaceholder extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
    aspectRatio: PropTypes.string,
  };

  handleClick = () => {
    const { dispatch } = this.props;
    dispatch(removePictureInPicture());
  };

  render () {
    const { aspectRatio } = this.props;

    return (
      <div className='picture-in-picture-placeholder' style={{ aspectRatio }} role='button' tabIndex={0} onClick={this.handleClick}>
        <Icon id='window-restore' />
        <FormattedMessage id='picture_in_picture.restore' defaultMessage='Put it back' />
      </div>
    );
  }

}

export default connect()(PictureInPicturePlaceholder);
