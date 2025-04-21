require_relative "bootstrap"

configs = $databases.map do |n, db_path|
  config_hash = {
    "adapter" => 'sqlite3',
    "database" => db_path,
    "pool" => 4
  }
  ["database_#{n}", config_hash]
end.to_h
configs_for_default_env = {"default_env" => configs}

# puts YAML.dump(configs_for_default_env)
# default_env:
#   database_0:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/0.sqlite3"
#     pool: 4
#   database_1:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/1.sqlite3"
#     pool: 4
#   database_10:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/10.sqlite3"
#     pool: 4
#   database_11:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/11.sqlite3"
#     pool: 4
#   database_12:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/12.sqlite3"
#     pool: 4
#   database_13:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/13.sqlite3"
#     pool: 4
#   database_14:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/14.sqlite3"
#     pool: 4
#   database_15:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/15.sqlite3"
#     pool: 4
#   database_2:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/2.sqlite3"
#     pool: 4
#   database_3:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/3.sqlite3"
#     pool: 4
#   database_4:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/4.sqlite3"
#     pool: 4
#   database_5:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/5.sqlite3"
#     pool: 4
#   database_6:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/6.sqlite3"
#     pool: 4
#   database_7:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/7.sqlite3"
#     pool: 4
#   database_8:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/8.sqlite3"
#     pool: 4
#   database_9:
#     adapter: sqlite3
#     database: "/Users/julik/Code/sqlite3-multitenancy-ar/9.sqlite3"
#     pool: 4

ActiveRecord::Base.configurations = configs_for_default_env
ActiveRecord::Base.establish_connection

perform_tests def named_databases(n, from_database_paths)
  ActiveRecord::Base.connected_to(role: "database_#{n}") do
    query_and_compare!(n)
  end
end
