import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { defineMessages, FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { Button } from 'mastodon/components/button';
import { toServerSideType } from 'mastodon/utils/filters';

const messages = defineMessages({
  expired_title:                { id: 'custom_filters_modal.added.expired_title',                defaultMessage: 'Expired filter!' },
  expired_explanation:          { id: 'custom_filters_modal.added.expired_explanation',          defaultMessage: 'This filter has expired, you will need to change the expiration date for it to apply.' },
  context_mismatch_title:       { id: 'custom_filters_modal.added.context_mismatch_title',       defaultMessage: 'Context mismatch!' },
  context_mismatch_explanation: { id: 'custom_filters_modal.added.context_mismatch_explanation', defaultMessage: 'This filter does not apply to the context in which you have accessed this post. If you want the post to be filtered in this context too, you will have to edit the filter.' },
  settings_link:                { id: 'custom_filters_modal.added.settings_link',                defaultMessage: 'settings page' },
  title:                        { id: 'custom_filters_modal.added.title',                        defaultMessage: 'Filter added!'},
  short_explanation:            { id: 'custom_filters_modal.added.short_explanation',            defaultMessage: 'This post has been added to the following filter: {title}.' },
  review_and_configure_title:   { id: 'custom_filters_modal.added.review_and_configure_title',   defaultMessage: 'Filter settings' },
  review_and_configure:         { id: 'custom_filters_modal.added.review_and_configure',         defaultMessage: 'To review and further configure this filter, go to the {settings_link}.' },
  close:                        { id: 'custom_filters_modal.added.close',                        defaultMessage: 'Done' },
});

const mapStateToProps = (state, { filterId }) => ({
  filter: state.getIn(['filters', filterId]),
});

class AddedToFilter extends PureComponent {

  static propTypes = {
    onClose: PropTypes.func.isRequired,
    contextType: PropTypes.string,
    filter: ImmutablePropTypes.map.isRequired,
    dispatch: PropTypes.func.isRequired,
  };

  handleCloseClick = () => {
    const { onClose } = this.props;
    onClose();
  };

  render () {
    const { filter, contextType } = this.props;

    let expiredMessage = null;
    if (filter.get('expires_at') && filter.get('expires_at') < new Date()) {
      expiredMessage = (
        <>
          <h4 className='report-dialog-modal__subtitle'><FormattedMessage {...messages.expired_title} /></h4>
          <p className='report-dialog-modal__lead'><FormattedMessage {...messages.expired_explanation} /></p>
        </>
      );
    }

    let contextMismatchMessage = null;
    if (contextType && !filter.get('context').includes(toServerSideType(contextType))) {
      contextMismatchMessage = (
        <>
          <h4 className='report-dialog-modal__subtitle'><FormattedMessage {...messages.context_mismatch_title} /></h4>
          <p className='report-dialog-modal__lead'><FormattedMessage {...messages.context_mismatch_explanation} /></p>
        </>
      );
    }

    const settings_link = (
      <a href={`/filters/${filter.get('id')}/edit`}>
        <FormattedMessage {...messages.settings_link} />
      </a>
    );

    return (
      <>
        <h3 className='report-dialog-modal__title'><FormattedMessage {...messages.title} /></h3>
        <p className='report-dialog-modal__lead'>
          <FormattedMessage
            {...messages.short_explanation}
            values={{ title: filter.get('title') }}
          />
        </p>

        {expiredMessage}
        {contextMismatchMessage}

        <h4 className='report-dialog-modal__subtitle'><FormattedMessage {...messages.review_and_configure_title} /></h4>
        <p className='report-dialog-modal__lead'>
          <FormattedMessage
            {...messages.review_and_configure}
            values={{ settings_link }}
          />
        </p>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleCloseClick}><FormattedMessage {...messages.close} /></Button>
        </div>
      </>
    );
  }

}

export default connect(mapStateToProps)(AddedToFilter);
