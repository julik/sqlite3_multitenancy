require_relative "bootstrap"

configs = $databases.map do |n, db_path|
  connection_config = {
    adapter: 'sqlite3',
    database: db_path
  }
  ["database_#{n}", connection_config]
end.to_h
ActiveRecord::Base.establish_connection(configs)

perform_tests def named_databases(from_db_n, from_database_paths)
  ActiveRecord::Base.connected_to("database_#{n}") do
    query_and_compare!(from_db_n)
  end
end
