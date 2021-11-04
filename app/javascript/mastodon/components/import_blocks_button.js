import React from 'react';
import { FormattedMessage } from 'react-intl';
import { blockAccount, unblockAccount } from '../actions/accounts';
import ImmutablePropTypes, { list } from 'react-immutable-proptypes';
import PropTypes from 'prop-types';
import { connect } from 'react-redux';


const mapStateToProps = (state) => ({
});

export default @connect(mapStateToProps)
class ImportBlocksButton extends React.PureComponent {
    static propTypes = {
        accounts: ImmutablePropTypes.list.isRequired,
        dispatch: PropTypes.func.isRequired,
    };


    handleClick = () => {
        this.props.accounts.map((acc) => {
            if (acc.getIn(['relationship', 'blocking'])) {
                console.log("tutaj odblok")
                this.props.dispatch(unblockAccount(acc.get('id')));
            } else {
                // this.props.dispatch(blockAccount(acc.get('id')));
                console.log("tutaj blok")
            }
        })
    }
    render() {
        return (
            <button onClick={this.handleClick} className='column-back-button'>
                {/* <FormattedMessage id='column_back_button.label' defaultMessage='Import' /> */}
                Import
            </button>
        );
    }
}
