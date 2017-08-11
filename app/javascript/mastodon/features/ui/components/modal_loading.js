import React from 'react';

import LoadingIndicator from '../../../components/loading_indicator';

// Keep the markup in sync with <BundleModalError />
// (make sure they have the same dimensions)
const ModalLoading = () => (
  <div className='modal-root__modal error-modal'>
    <div className='error-modal__body'>
      <LoadingIndicator />
    </div>
    <div className='error-modal__footer'>
      <div>
        <button className='error-modal__nav onboarding-modal__skip' />
      </div>
    </div>
  </div>
);

export default ModalLoading;
