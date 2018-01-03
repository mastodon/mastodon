//  Package imports.
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Actions.
import { openModal } from 'flavours/glitch/actions/modal';
import {
  changeSearch,
  clearSearch,
  showSearch,
  submitSearch,
} from 'flavours/glitch/actions/search';

//  Components.
import Composer from 'flavours/glitch/features/composer';
import DrawerAccount from './account';
import DrawerHeader from './header';
import DrawerResults from './results';
import DrawerSearch from './search';

//  Utils.
import { me } from 'flavours/glitch/util/initial_state';
import { wrap } from 'flavours/glitch/util/redux_helpers';

//  State mapping.
const mapStateToProps = state => ({
  account: state.getIn(['accounts', me]),
  columns: state.getIn(['settings', 'columns']),
  results: state.getIn(['search', 'results']),
  searchHidden: state.getIn(['search', 'hidden']),
  searchValue: state.getIn(['search', 'value']),
  submitted: state.getIn(['search', 'submitted']),
});

//  Dispatch mapping.
const mapDispatchToProps = {
  onChange: changeSearch,
  onClear: clearSearch,
  onShow: showSearch,
  onSubmit: submitSearch,
  onOpenSettings: openModal.bind(null, 'SETTINGS', {}),
};

//  The component.
class Drawer extends React.Component {

  //  Constructor.
  constructor (props) {
    super(props);
  }

  //  Rendering.
  render () {
    const {
      account,
      columns,
      intl,
      multiColumn,
      onChange,
      onClear,
      onOpenSettings,
      onShow,
      onSubmit,
      results,
      searchHidden,
      searchValue,
      submitted,
    } = this.props;

    //  The result.
    return (
      <div className='drawer'>
        {multiColumn ? (
          <DrawerHeader
            columns={columns}
            intl={intl}
            onSettingsClick={onOpenSettings}
          />
        ) : null}
        <DrawerSearch
          intl={intl}
          onChange={onChange}
          onClear={onClear}
          onShow={onShow}
          onSubmit={onSubmit}
          submitted={submitted}
          value={searchValue}
        />
        <div className='contents'>
          <DrawerAccount account={account} />
          <Composer />
          <DrawerResults
            results={results}
            visible={submitted && !searchHidden}
          />
        </div>
      </div>
    );
  }

}

//  Props.
Drawer.propTypes = {
  intl: PropTypes.object.isRequired,
  multiColumn: PropTypes.bool,

  //  State props.
  account: ImmutablePropTypes.map,
  columns: ImmutablePropTypes.list,
  results: ImmutablePropTypes.map,
  searchHidden: PropTypes.bool,
  searchValue: PropTypes.string,
  submitted: PropTypes.bool,

  //  Dispatch props.
  onChange: PropTypes.func,
  onClear: PropTypes.func,
  onShow: PropTypes.func,
  onSubmit: PropTypes.func,
  onOpenSettings: PropTypes.func,
};

//  Connecting and export.
export { Drawer as WrappedComponent };
export default wrap(Drawer, mapStateToProps, mapDispatchToProps, true);
