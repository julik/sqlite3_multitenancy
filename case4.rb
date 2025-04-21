require_relative "bootstrap"

ActiveRecord::Base.legacy_connection_handling = false if ActiveRecord::Base.respond_to?(:legacy_connection_handling)
$databases.each_pair do |n, db_path|
  config_hash = {
    "adapter" => 'sqlite3',
    "database" => db_path,
    "pool" => 4
  }
  ActiveRecord::Base.connection_handler.establish_connection(config_hash, role: "database_#{n}")
end

def named_databases_as_roles_using_connected_to(n, from_database_paths)
  ActiveRecord::Base.connected_to(role: "database_#{n}") do
    query_and_compare!(n)
  end
end

perform_tests :named_databases_as_roles_using_connected_to, parallel_flows: 6, flow_iterations: 32
