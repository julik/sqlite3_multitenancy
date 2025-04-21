require_relative "bootstrap"

ActiveRecord::Base.legacy_connection_handling = false if ActiveRecord::Base.respond_to?(:legacy_connection_handling)

MUX = Mutex.new
def named_databases_as_roles_using_connected_to_with_fiber_and_just_in_time_establish(n, from_database_paths)
  role_name = "database_#{n}"
  MUX.synchronize do
    if ActiveRecord::Base.connection_handler.connection_pool_list("database_#{n}").none?
      db_path = from_database_paths.fetch(n)
      config_hash = {
        "adapter" => 'sqlite3',
        "database" => db_path,
        "pool" => 8
      }
      ActiveRecord::Base.connection_handler.establish_connection(config_hash, role: role_name)
    end
  end

  role_playing_fiber = Fiber.new do
    ActiveRecord::Base.connected_to(role: "database_#{n}") do
      Fiber.yield
    end
  end
  role_playing_fiber.resume
  query_and_compare!(n)
  role_playing_fiber.resume
end

perform_tests :named_databases_as_roles_using_connected_to_with_fiber_and_just_in_time_establish, parallel_flows: 4, flow_iterations: 32
