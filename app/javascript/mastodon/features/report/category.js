import React from 'react';
import PropTypes from 'prop-types';
import { defineMessages, injectIntl, FormattedMessage } from 'react-intl';
import Button from 'mastodon/components/button';
import classNames from 'classnames';

const messages = defineMessages({
  dislike: { id: 'report.reasons.dislike', defaultMessage: 'I don\'t like it' },
  dislike_description: { id: 'report.reasons.dislike_description', defaultMessage: 'It is not something you want to see' },
  spam: { id: 'report.reasons.spam', defaultMessage: 'It\'s spam' },
  spam_description: { id: 'report.reasons.spam_description', defaultMessage: 'Malicious links, fake engagement, or repetetive replies' },
  violation: { id: 'report.reasons.violation', defaultMessage: 'It violates server rules' },
  violation_description: { id: 'report.reasons.violation_description', defaultMessage: 'You are aware that it breaks specific rules' },
  other: { id: 'report.reasons.other', defaultMessage: 'It\'s something else' },
  other_description: { id: 'report.reasons.other_description', defaultMessage: 'The issue does not fit into other categories' },
});

export default @injectIntl
class Category extends React.PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    category: PropTypes.string,
    onChangeCategory: PropTypes.func.isRequired,
    intl: PropTypes.object.isRequired,
  };

  handleNextClick = () => {
    const { onNextStep, category } = this.props;

    switch(category) {
    case 'dislike':
      onNextStep('thanks');
      break;
    case 'violation':
      onNextStep('rules');
      break;
    default:
      onNextStep('statuses');
      break;
    }
  };

  handleCategoryChange = e => {
    const { onChangeCategory } = this.props;

    if (e.target.checked) {
      onChangeCategory(e.target.value);
    }
  };

  handleCategoryKeyPress = e => {
    const { onChangeCategory } = this.props;

    if (e.key === 'Enter' || e.key === ' ') {
      e.stopPropagation();
      e.preventDefault();

      onChangeCategory(e.target.getAttribute('data-value'));
    }
  }

  render () {
    const { category, intl } = this.props;

    const options = [
      'dislike',
      'spam',
      'violation',
      'other',
    ];

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.category.title' defaultMessage="Tell us what's going on with this post" /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.category.subtitle' defaultMessage='Choose the best match' /></p>

        {options.map(item => (
          <label key={item} className='dialog-option poll__option selectable'>
            <input type='radio' name='category' value={item} checked={category === item} onChange={this.handleCategoryChange} />

            <span
              className={classNames('poll__input', { active: category === item })}
              tabIndex='0'
              role='radio'
              onKeyPress={this.handleCategoryKeyPress}
              aria-checked={category === item}
              aria-label={intl.formatMessage(messages[item])}
              data-value={item}
            />

            <span className='poll__option__text'>
              <strong>{intl.formatMessage(messages[item])}</strong>
              {intl.formatMessage(messages[`${item}_description`])}
            </span>
          </label>
        ))}

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleNextClick} disabled={category === null}><FormattedMessage id='report.next' defaultMessage='Next' /></Button>
        </div>
      </React.Fragment>
    );
  }

}
