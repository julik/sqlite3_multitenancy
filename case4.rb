require_relative "bootstrap"

ActiveRecord::Base.legacy_connection_handling = false
$databases.each_pair do |n, db_path|
  config_hash = {
    "adapter" => 'sqlite3',
    "database" => db_path,
    "pool" => 4
  }
  ActiveRecord::Base.connection_handler.establish_connection(config_hash, role: "database_#{n}")
end

def named_databases_as_roles(n, from_database_paths)
  ActiveRecord::Base.connected_to(role: "database_#{n}") do
    query_and_compare!(n)
  end
end
perform_tests :named_databases_as_roles, parallel_flows: 8, flow_iterations: 16
