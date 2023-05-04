# frozen_string_literal: true

if Rails.env.development?
  task :set_annotation_options do
    Annotate.set_defaults(
      'routes' => 'false',
      'models' => 'true',
      'position_in_routes' => 'before',
      'position_in_class' => 'before',
      'position_in_test' => 'before',
      'position_in_fixture' => 'before',
      'position_in_factory' => 'before',
      'position_in_serializer' => 'before',
      'show_foreign_keys' => 'false',
      'show_indexes' => 'false',
      'simple_indexes' => 'false',
      'model_dir' => 'app/models',
      'root_dir' => '',
      'include_version' => 'false',
      'require' => '',
      'exclude_tests' => 'true',
      'exclude_fixtures' => 'true',
      'exclude_factories' => 'true',
      'exclude_serializers' => 'true',
      'exclude_scaffolds' => 'true',
      'exclude_controllers' => 'true',
      'exclude_helpers' => 'true',
      'ignore_model_sub_dir' => 'false',
      'ignore_columns' => nil,
      'ignore_routes' => nil,
      'ignore_unknown_models' => 'false',
      'hide_limit_column_types' => 'integer,boolean',
      'skip_on_db_migrate' => 'false',
      'format_bare' => 'true',
      'format_rdoc' => 'false',
      'format_markdown' => 'false',
      'sort' => 'false',
      'force' => 'false',
      'trace' => 'false',
      'wrapper_open' => nil,
      'wrapper_close' => nil
    )
  end

  Annotate.load_tasks
end
