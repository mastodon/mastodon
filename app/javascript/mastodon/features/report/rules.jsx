import PropTypes from 'prop-types';
import { PureComponent } from 'react';

import { FormattedMessage } from 'react-intl';

import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';

import { Button } from 'mastodon/components/button';
import { NavigationFocusTarget } from 'mastodon/components/navigation_focus_target';

import Option from './components/option';

const mapStateToProps = state => ({
  rules: state.getIn(['server', 'server', 'item', 'rules']),
  locale: state.getIn(['meta', 'locale']),
});

class Rules extends PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    rules: PropTypes.arrayOf(PropTypes.object),
    locale: PropTypes.string,
    selectedRuleIds: ImmutablePropTypes.set.isRequired,
    onToggle: PropTypes.func.isRequired,
  };

  handleNextClick = () => {
    const { onNextStep } = this.props;
    onNextStep('statuses');
  };

  handleRulesToggle = (value, checked) => {
    const { onToggle } = this.props;
    onToggle(value, checked);
  };

  render () {
    const { rules, locale, selectedRuleIds } = this.props;

    return (
      <>
        <NavigationFocusTarget as='h1' className='report-dialog-modal__title'>
          <FormattedMessage id='report.rules.title' defaultMessage='Which rules are being violated?' />
        </NavigationFocusTarget>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.rules.subtitle' defaultMessage='Select all that apply' /></p>

        <div>
          {rules.map(item => (
            <Option
              key={item.id}
              name='rule_ids'
              value={item.id}
              checked={selectedRuleIds.includes(item.id)}
              onToggle={this.handleRulesToggle}
              label={item.translations?.[locale]?.text || item.translations?.[locale.split('-')[0]]?.text || item.text}
              multiple
            />
          ))}
        </div>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleNextClick} disabled={selectedRuleIds.size < 1}><FormattedMessage id='report.next' defaultMessage='Next' /></Button>
        </div>
      </>
    );
  }

}

export default connect(mapStateToProps)(Rules);
