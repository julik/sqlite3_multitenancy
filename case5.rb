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

def named_databases_as_roles_using_connected_to_with_fiber(n, from_database_paths)
  role_playing_fiber = Fiber.new do
    ActiveRecord::Base.connected_to(role: "database_#{n}") do
      Fiber.yield
    end
  end
  role_playing_fiber.resume
  query_and_compare!(n)
  role_playing_fiber.resume
end

perform_tests :named_databases_as_roles_using_connected_to_with_fiber, parallel_flows: 12, flow_iterations: 32
