import React from 'react';
import PropTypes from 'prop-types';
import { injectIntl, defineMessages, FormattedMessage } from 'react-intl';
import Button from 'flavours/glitch/components/button';
import Toggle from 'react-toggle';

const messages = defineMessages({
  placeholder: { id: 'report.placeholder', defaultMessage: 'Type or paste additional comments' },
});

class Comment extends React.PureComponent {

  static propTypes = {
    onSubmit: PropTypes.func.isRequired,
    comment: PropTypes.string.isRequired,
    onChangeComment: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
    isSubmitting: PropTypes.bool,
    forward: PropTypes.bool,
    isRemote: PropTypes.bool,
    domain: PropTypes.string,
    onChangeForward: PropTypes.func.isRequired,
  };

  handleClick = () => {
    const { onSubmit } = this.props;
    onSubmit();
  };

  handleChange = e => {
    const { onChangeComment } = this.props;
    onChangeComment(e.target.value);
  };

  handleKeyDown = e => {
    if (e.keyCode === 13 && (e.ctrlKey || e.metaKey)) {
      this.handleClick();
    }
  };

  handleForwardChange = e => {
    const { onChangeForward } = this.props;
    onChangeForward(e.target.checked);
  };

  render () {
    const { comment, isRemote, forward, domain, isSubmitting, intl } = this.props;

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.comment.title' defaultMessage='Is there anything else you think we should know?' /></h3>

        <textarea
          className='report-dialog-modal__textarea'
          placeholder={intl.formatMessage(messages.placeholder)}
          value={comment}
          onChange={this.handleChange}
          onKeyDown={this.handleKeyDown}
          disabled={isSubmitting}
        />

        {isRemote && (
          <React.Fragment>
            <p className='report-dialog-modal__lead'><FormattedMessage id='report.forward_hint' defaultMessage='The account is from another server. Send an anonymized copy of the report there as well?' /></p>

            <label className='report-dialog-modal__toggle'>
              <Toggle checked={forward} disabled={isSubmitting} onChange={this.handleForwardChange} />
              <FormattedMessage id='report.forward' defaultMessage='Forward to {target}' values={{ target: domain }} />
            </label>
          </React.Fragment>
        )}

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleClick} disabled={isSubmitting}><FormattedMessage id='report.submit' defaultMessage='Submit report' /></Button>
        </div>
      </React.Fragment>
    );
  }

}

export default injectIntl(Comment);
