class AbSplitTesterGenerator < Rails::Generator::NamedBase
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate', :migration_file_name => "create_ab_split_test_hits"
    end
  end
end