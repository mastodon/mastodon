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
  onRemove,
  progress,
  uploading,
}) {
  const computedClass = classNames('composer--upload_form', { uploading });

  //  The result.
  return (
    <div className={computedClass}>
      {uploading ? <ComposerUploadFormProgress progress={progress} /> : null}
      {media ? (
        <div className='content'>
          {media.map(item => (
            <ComposerUploadFormItem
              description={item.get('description')}
              key={item.get('id')}
              id={item.get('id')}
              intl={intl}
              preview={item.get('preview_url')}
              onChangeDescription={onChangeDescription}
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
  onChangeDescription: PropTypes.func,
  onRemove: PropTypes.func,
  progress: PropTypes.number,
  uploading: PropTypes.bool,
};
