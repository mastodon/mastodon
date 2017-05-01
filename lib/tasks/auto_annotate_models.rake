# NOTE: only doing this in development as some production environments (Heroku)
# NOTE: are sensitive to local FS writes, and besides -- it's just not proper
# NOTE: to have a dev-mode tool do its thing in production.
if Rails.env.development?
  task :set_annotation_options do
    # You can override any of these by setting an environment variable of the
    # same name.
    Annotate.set_defaults(
      'routes'                  => 'false',
      'position_in_routes'      => 'before',
      'position_in_class'       => 'before',
      'position_in_test'        => 'before',
      'position_in_fixture'     => 'before',
      'position_in_factory'     => 'before',
      'position_in_serializer'  => 'before',
      'show_foreign_keys'       => 'true',
      'show_indexes'            => 'true',
      'simple_indexes'          => 'false',
      'model_dir'               => 'app/models',
      'root_dir'                => '',
      'include_version'         => 'false',
      'require'                 => '',
      'exclude_tests'           => 'false',
      'exclude_fixtures'        => 'false',
      'exclude_factories'       => 'false',
      'exclude_serializers'     => 'false',
      'exclude_scaffolds'       => 'true',
      'exclude_controllers'     => 'true',
      'exclude_helpers'         => 'true',
      'ignore_model_sub_dir'    => 'false',
      'ignore_columns'          => nil,
      'ignore_routes'           => nil,
      'ignore_unknown_models'   => 'false',
      'hide_limit_column_types' => 'integer,boolean',
      'skip_on_db_migrate'      => 'false',
      'format_bare'             => 'true',
      'format_rdoc'             => 'false',
      'format_markdown'         => 'false',
      'sort'                    => 'false',
      'force'                   => 'false',
      'trace'                   => 'false',
      'wrapper_open'            => nil,
      'wrapper_close'           => nil
    )
  end

  Annotate.load_tasks
end
