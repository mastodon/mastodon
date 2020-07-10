import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import Audio from 'flavours/glitch/features/audio';
import { connect } from 'react-redux';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { FormattedMessage } from 'react-intl';
import classNames from 'classnames';
import Icon from 'flavours/glitch/components/icon';

const mapStateToProps = (state, { status }) => ({
  account: state.getIn(['accounts', status.get('account')]),
});

export default @connect(mapStateToProps)
class AudioModal extends ImmutablePureComponent {

  static propTypes = {
    media: ImmutablePropTypes.map.isRequired,
    status: ImmutablePropTypes.map,
    options: PropTypes.shape({
      autoPlay: PropTypes.bool,
    }),
    account: ImmutablePropTypes.map,
    onClose: PropTypes.func.isRequired,
  };

  static contextTypes = {
    router: PropTypes.object,
  };

  handleStatusClick = e => {
    if (e.button === 0 && !(e.ctrlKey || e.metaKey)) {
      e.preventDefault();
      this.context.router.history.push(`/statuses/${this.props.status.get('id')}`);
    }
  }

  render () {
    const { media, status, account } = this.props;
    const options = this.props.options || {};

    return (
      <div className='modal-root__modal audio-modal'>
        <div className='audio-modal__container'>
          <Audio
            src={media.get('url')}
            alt={media.get('description')}
            duration={media.getIn(['meta', 'original', 'duration'], 0)}
            height={150}
            poster={media.get('preview_url') || account.get('avatar_static')}
            backgroundColor={media.getIn(['meta', 'colors', 'background'])}
            foregroundColor={media.getIn(['meta', 'colors', 'foreground'])}
            accentColor={media.getIn(['meta', 'colors', 'accent'])}
            autoPlay={options.autoPlay}
          />
        </div>

        {status && (
          <div className={classNames('media-modal__meta')}>
            <a href={status.get('url')} onClick={this.handleStatusClick}><Icon id='comments' /> <FormattedMessage id='lightbox.view_context' defaultMessage='View context' /></a>
          </div>
        )}
      </div>
    );
  }

}
