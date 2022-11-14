import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { FormattedMessage } from 'react-intl';
import { toServerSideType } from 'mastodon/utils/filters';
import Button from 'mastodon/components/button';
import { connect } from 'react-redux';

const mapStateToProps = (state, { filterId }) => ({
  filter: state.getIn(['filters', filterId]),
});

export default @connect(mapStateToProps)
class AddedToFilter extends React.PureComponent {

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
        <React.Fragment>
          <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='filter_modal.added.expired_title' defaultMessage='Expired filter!' /></h4>
          <p className='report-dialog-modal__lead'>
            <FormattedMessage
              id='filter_modal.added.expired_explanation'
              defaultMessage='This filter category has expired, you will need to change the expiration date for it to apply.'
            />
          </p>
        </React.Fragment>
      );
    }

    let contextMismatchMessage = null;
    if (contextType && !filter.get('context').includes(toServerSideType(contextType))) {
      contextMismatchMessage = (
        <React.Fragment>
          <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='filter_modal.added.context_mismatch_title' defaultMessage='Context mismatch!' /></h4>
          <p className='report-dialog-modal__lead'>
            <FormattedMessage
              id='filter_modal.added.context_mismatch_explanation'
              defaultMessage='This filter category does not apply to the context in which you have accessed this post. If you want the post to be filtered in this context too, you will have to edit the filter.'
            />
          </p>
        </React.Fragment>
      );
    }

    const settings_link = (
      <a href={`/filters/${filter.get('id')}/edit`}>
        <FormattedMessage
          id='filter_modal.added.settings_link'
          defaultMessage='settings page'
        />
      </a>
    );

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='filter_modal.added.title' defaultMessage='Filter added!' /></h3>
        <p className='report-dialog-modal__lead'>
          <FormattedMessage
            id='filter_modal.added.short_explanation'
            defaultMessage='This post has been added to the following filter category: {title}.'
            values={{ title: filter.get('title') }}
          />
        </p>

        {expiredMessage}
        {contextMismatchMessage}

        <h4 className='report-dialog-modal__subtitle'><FormattedMessage id='filter_modal.added.review_and_configure_title' defaultMessage='Filter settings' /></h4>
        <p className='report-dialog-modal__lead'>
          <FormattedMessage
            id='filter_modal.added.review_and_configure'
            defaultMessage='To review and further configure this filter category, go to the {settings_link}.'
            values={{ settings_link }}
          />
        </p>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleCloseClick}><FormattedMessage id='report.close' defaultMessage='Done' /></Button>
        </div>
      </React.Fragment>
    );
  }

}
