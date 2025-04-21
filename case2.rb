require_relative "bootstrap"

perform_tests def establish_then_remove_with_pool(from_db_n, from_database_paths)
  db_path = from_database_paths.fetch(from_db_n)
  config = {adapter: 'sqlite3', database: db_path, pool: 4}
  pool = ActiveRecord::Base.establish_connection(config)
  query_and_compare!(from_db_n)
ensure
  ActiveRecord::Base.remove_connection if pool
end
