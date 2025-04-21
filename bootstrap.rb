require 'bundler/inline'
require "logger"

gemfile do
  source 'https://rubygems.org'
  gem "activerecord", "~> 6", require: "active_record"
  gem "sqlite3", "~> 1.1" # This has to be of a version activerecord supports, so can't be 2.x
end

16.times do |n|
  file = "#{n}.sqlite3"
  FileUtils.rm_rf(file)
  SQLite3::Database.open(file) do |db|
    db.execute("CREATE TABLE some_values (id INTEGER PRIMARY KEY AUTOINCREMENT, val INTEGER)")
    n.times do
      db.execute("INSERT INTO some_values (val) VALUES (?)", [n])
    end
  end
end

$databases = Dir.glob(__dir__ + "/*.sqlite3").sort.map do |path|
  n = SQLite3::Database.open(path) do |db|
    db.get_first_value("SELECT COUNT(*) FROM some_values")
  end
  [n, path]
end.to_h

class SomeValue < ActiveRecord::Base
  self.table_name = "some_values"
end

def query_and_compare!(n)
  num_rows = SomeValue.count
  if num_rows != n
    raise "Mismatch: expected to have queried DB #{n} but we queried #{num_rows} instead"
  end
end

$stdout.sync = true

def perform_tests(method_name, parallel_flows: 2, flow_iterations: 4)
  puts "\nSync test of #{method_name.inspect} :"
  rng = Random.new(42)

  exceptions = []
  
  (parallel_flows * flow_iterations).times.map do
    n = $databases.keys.sample(random: rng)
    send(method_name, n, $databases)
    $stdout << "."
  rescue => e
    $stdout << "X"
    exceptions << e
  end

  puts "\nThreaded test of #{method_name.inspect} :"
  threads = parallel_flows.times.map do
    Thread.new do
      flow_iterations.times do
        n = $databases.keys.sample(random: rng)
        send(method_name, n, $databases)
        $stdout << "."
      rescue => e
        $stdout << "X"
        exceptions << e
      end
    end
  end
  threads.map(&:join)
  exceptions.uniq!(&:class)
  return unless exceptions.any?

  exceptions.each do |e|
    warn "Exception was raised during one of the tasks: #{e.class} - #{e.message}"
    e.backtrace.to_a.each do |line|
      warn line
    end
  end
end
