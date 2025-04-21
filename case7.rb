require_relative "bootstrap"
require "digest"

ActiveRecord::Base.legacy_connection_handling = false if ActiveRecord::Base.respond_to?(:legacy_connection_handling)

class DBFileContext
  POOL_CHECK_MUTEX = Mutex.new
  
  def initialize(single_connection_config_hash)
    @config_hash = single_connection_config_hash.with_indifferent_access
    @role_name = "tenant_db_#{Digest::SHA1.hexdigest(@config_hash.fetch(:database))}"
    @context_fibers = []
  end

  def enter
    create_pool_for_database_if_none_available!
    context_fiber = Fiber.new do
      ActiveRecord::Base.connected_to(role: @role_name) { Fiber.yield }
    end
    context_fiber.resume
    @context_fibers << context_fiber
    true
  end

  def leave
    last_context_fiber = @context_fibers.pop
    return unless last_context_fiber
    last_context_fiber.resume
  end

  def with(&blk)
    create_pool_for_database_if_none_available!
    ActiveRecord::Base.connected_to(role: @role_name, &blk)
  end

  def create_pool_for_database_if_none_available!
    POOL_CHECK_MUTEX.synchronize do
      if ActiveRecord::Base.connection_handler.connection_pool_list(@role_name).none?
        ActiveRecord::Base.connection_handler.establish_connection(@config_hash, role: @role_name)
      end
    end
  end
end

def named_databases_as_roles_using_connected_to_with_fiber_and_just_in_time_establish(n, from_database_paths)
  db_path = from_database_paths.fetch(n)
  config_hash = {
    "adapter" => 'sqlite3',
    "database" => db_path,
    "pool" => 8
  }
  context = DBFileContext.new(config_hash)
  context.enter
  query_and_compare!(n)
  context.leave
end

perform_tests :named_databases_as_roles_using_connected_to_with_fiber_and_just_in_time_establish, parallel_flows: 8, flow_iterations: 128
