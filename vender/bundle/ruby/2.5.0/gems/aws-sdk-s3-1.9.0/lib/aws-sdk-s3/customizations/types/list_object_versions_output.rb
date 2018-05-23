class Aws::S3::Types::ListObjectVersionsOutput

  # TODO : Remove this customization once the resource code
  #        generator correct handles the JMESPath || expression.
  #        Only used by the Bucket#object_versions collection.
  # @api private
  def versions_delete_markers
    versions + delete_markers
  end

end
