import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import { connect } from 'react-redux';

import { removePictureInPicture } from 'flavours/glitch/actions/picture_in_picture';
import { Icon } from 'flavours/glitch/components/icon';

class PictureInPicturePlaceholder extends PureComponent {

  static propTypes = {
    dispatch: PropTypes.func.isRequired,
  };

  handleClick = () => {
    const { dispatch } = this.props;
    dispatch(removePictureInPicture());
  };

  render () {
    return (
      <div className='picture-in-picture-placeholder' role='button' tabIndex={0} onClick={this.handleClick}>
        <Icon id='window-restore' />
        <FormattedMessage id='picture_in_picture.restore' defaultMessage='Put it back' />
      </div>
    );
  }

}

export default connect()(PictureInPicturePlaceholder);
