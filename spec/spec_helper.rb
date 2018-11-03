require 'bundler/setup'
require 'fluent/version'
require 'fluent/test'

if Gem::Version.new(Fluent::VERSION) >= Gem::Version.new('0.14')
  require 'fluent/test/driver/filter'
end

require 'fluent/plugin/filter_parse_audit_log'
require 'timecop'

ENV['TZ'] = 'UTC'

# prevent Test::Unit's AutoRunner from executing during RSpec's rake task
Test::Unit.run = true if defined?(Test::Unit) && Test::Unit.respond_to?(:run=)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.before(:all) do
    Fluent::Test.setup
  end
end

module SpecHelper
  def create_driver
    fluentd_conf = <<~EOS
      type parse_audit_log
    EOS

    if Gem::Version.new(Fluent::VERSION) >= Gem::Version.new('0.14')
      Fluent::Test::Driver::Input.new(FluentParseAuditLogFilter).configure(fluentd_conf)
    else
      Fluent::Test::OutputTestDriver.new(FluentParseAuditLogFilter).configure(fluentd_conf)
    end
  end
end
include SpecHelper
