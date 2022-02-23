import React from 'react';
import PropTypes from 'prop-types';
import ImmutablePropTypes from 'react-immutable-proptypes';
import { connect } from 'react-redux';
import { FormattedMessage } from 'react-intl';
import Button from 'flavours/glitch/components/button';
import Option from './components/option';

const mapStateToProps = state => ({
  rules: state.get('rules'),
});

export default @connect(mapStateToProps)
class Rules extends React.PureComponent {

  static propTypes = {
    onNextStep: PropTypes.func.isRequired,
    rules: ImmutablePropTypes.list,
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
    const { rules, selectedRuleIds } = this.props;

    return (
      <React.Fragment>
        <h3 className='report-dialog-modal__title'><FormattedMessage id='report.rules.title' defaultMessage='Which rules are being violated?' /></h3>
        <p className='report-dialog-modal__lead'><FormattedMessage id='report.rules.subtitle' defaultMessage='Select all that apply' /></p>

        <div>
          {rules.map(item => (
            <Option
              key={item.get('id')}
              name='rule_ids'
              value={item.get('id')}
              checked={selectedRuleIds.includes(item.get('id'))}
              onToggle={this.handleRulesToggle}
              label={item.get('text')}
              multiple
            />
          ))}
        </div>

        <div className='flex-spacer' />

        <div className='report-dialog-modal__actions'>
          <Button onClick={this.handleNextClick} disabled={selectedRuleIds.size < 1}><FormattedMessage id='report.next' defaultMessage='Next' /></Button>
        </div>
      </React.Fragment>
    );
  }

}
