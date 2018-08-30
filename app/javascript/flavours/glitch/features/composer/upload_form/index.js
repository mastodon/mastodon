//  Package imports.
import classNames from 'classnames';
import PropTypes from 'prop-types';
import React from 'react';
import ImmutablePropTypes from 'react-immutable-proptypes';

//  Components.
import ComposerUploadFormItem from './item';
import ComposerUploadFormProgress from './progress';

//  The component.
export default function ComposerUploadForm ({
  intl,
  media,
  onChangeDescription,
  onOpenFocalPointModal,
  onRemove,
  progress,
  uploading,
  handleRef,
}) {
  const computedClass = classNames('composer--upload_form', { uploading });

  //  The result.
  return (
    <div className={computedClass} ref={handleRef}>
      {uploading ? <ComposerUploadFormProgress progress={progress} /> : null}
      {media ? (
        <div className='content'>
          {media.map(item => (
            <ComposerUploadFormItem
              description={item.get('description')}
              key={item.get('id')}
              id={item.get('id')}
              intl={intl}
              focusX={item.getIn(['meta', 'focus', 'x'])}
              focusY={item.getIn(['meta', 'focus', 'y'])}
              mediaType={item.get('type')}
              preview={item.get('preview_url')}
              onChangeDescription={onChangeDescription}
              onOpenFocalPointModal={onOpenFocalPointModal}
              onRemove={onRemove}
            />
          ))}
        </div>
      ) : null}
    </div>
  );
}

//  Props.
ComposerUploadForm.propTypes = {
  intl: PropTypes.object.isRequired,
  media: ImmutablePropTypes.list,
  onChangeDescription: PropTypes.func.isRequired,
  onRemove: PropTypes.func.isRequired,
  progress: PropTypes.number,
  uploading: PropTypes.bool,
  handleRef: PropTypes.func,
};
