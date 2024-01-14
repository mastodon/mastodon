import PropTypes from 'prop-types';

import { defineMessages, FormattedMessage, injectIntl } from 'react-intl';

import { createSelector } from '@reduxjs/toolkit';
import { is, List as ImmutableList, Set as ImmutableSet } from 'immutable';
import ImmutablePropTypes from 'react-immutable-proptypes';
import ImmutablePureComponent from 'react-immutable-pure-component';
import { connect } from 'react-redux';

import { ReactComponent as CloseIcon } from '@material-symbols/svg-600/outlined/close.svg';

import { followAccount } from 'flavours/glitch/actions/accounts';
import { Button } from 'flavours/glitch/components/button';
import { IconButton } from 'flavours/glitch/components/icon_button';
import Option from 'flavours/glitch/features/report/components/option';
import { languages as preloadedLanguages } from 'flavours/glitch/initial_state';

const messages = defineMessages({
  close: { id: 'lightbox.close', defaultMessage: 'Close' },
});

const getAccountLanguages = createSelector([
  (state, accountId) => state.getIn(['timelines', `account:${accountId}`, 'items'], ImmutableList()),
  state => state.get('statuses'),
], (statusIds, statuses) =>
  new ImmutableSet(statusIds.map(statusId => statuses.get(statusId)).filter(status => !status.get('reblog')).map(status => status.get('language'))));

const mapStateToProps = (state, { accountId }) => ({
  acct: state.getIn(['accounts', accountId, 'acct']),
  availableLanguages: getAccountLanguages(state, accountId),
  selectedLanguages: ImmutableSet(state.getIn(['relationships', accountId, 'languages']) || ImmutableList()),
});

const mapDispatchToProps = (dispatch, { accountId }) => ({

  onSubmit (languages) {
    dispatch(followAccount(accountId, { languages }));
  },

});

class SubscribedLanguagesModal extends ImmutablePureComponent {

  static propTypes = {
    accountId: PropTypes.string.isRequired,
    acct: PropTypes.string.isRequired,
    availableLanguages: ImmutablePropTypes.setOf(PropTypes.string),
    selectedLanguages: ImmutablePropTypes.setOf(PropTypes.string),
    onClose: PropTypes.func.isRequired,
    languages: PropTypes.arrayOf(PropTypes.arrayOf(PropTypes.string)),
    intl: PropTypes.object.isRequired,
    submit: PropTypes.func.isRequired,
  };

  static defaultProps = {
    languages: preloadedLanguages,
  };

  state = {
    selectedLanguages: this.props.selectedLanguages,
  };

  handleLanguageToggle = (value, checked) => {
    const { selectedLanguages } = this.state;

    if (checked) {
      this.setState({ selectedLanguages: selectedLanguages.add(value) });
    } else {
      this.setState({ selectedLanguages: selectedLanguages.delete(value) });
    }
  };

  handleSubmit = () => {
    this.props.onSubmit(this.state.selectedLanguages.toArray());
    this.props.onClose();
  };

  renderItem (value) {
    const language = this.props.languages.find(language => language[0] === value);
    const checked = this.state.selectedLanguages.includes(value);

    if (!language) {
      return null;
    }

    return (
      <Option
        key={value}
        name='languages'
        value={value}
        label={language[1]}
        checked={checked}
        onToggle={this.handleLanguageToggle}
        multiple
      />
    );
  }

  render () {
    const { acct, availableLanguages, selectedLanguages, intl, onClose } = this.props;

    return (
      <div className='modal-root__modal report-dialog-modal'>
        <div className='report-modal__target'>
          <IconButton className='report-modal__close' title={intl.formatMessage(messages.close)} icon='times' iconComponent={CloseIcon} onClick={onClose} size={20} />
          <FormattedMessage id='subscribed_languages.target' defaultMessage='Change subscribed languages for {target}' values={{ target: <strong>{acct}</strong> }} />
        </div>

        <div className='report-dialog-modal__container'>
          <p className='report-dialog-modal__lead'><FormattedMessage id='subscribed_languages.lead' defaultMessage='Only posts in selected languages will appear on your home and list timelines after the change. Select none to receive posts in all languages.' /></p>

          <div>
            {availableLanguages.union(selectedLanguages).delete(null).map(value => this.renderItem(value))}
          </div>

          <div className='flex-spacer' />

          <div className='report-dialog-modal__actions'>
            <Button disabled={is(this.state.selectedLanguages, this.props.selectedLanguages)} onClick={this.handleSubmit}><FormattedMessage id='subscribed_languages.save' defaultMessage='Save changes' /></Button>
          </div>
        </div>
      </div>
    );
  }

}

export default connect(mapStateToProps, mapDispatchToProps)(injectIntl(SubscribedLanguagesModal));
