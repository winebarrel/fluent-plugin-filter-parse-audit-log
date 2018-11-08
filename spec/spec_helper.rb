require 'bundler/setup'
require 'fluent/version'
require 'fluent/test'

if Gem::Version.new(Fluent::VERSION) >= Gem::Version.new('0.14')
  require 'fluent/test/driver/filter'
end

require 'fluent/plugin/filter_parse_audit_log'
require 'timecop'

ENV['TZ'] = 'UTC'

Test::Unit::AutoRunner.need_auto_run = false

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

module FluentSpecHelper
  def create_driver(options = {})
    options = {
      type: 'parse_audit_log',
    }.merge(options)

    fluentd_conf = options.map {|k, v| "#{k} #{v}" }.join("\n")

    if Gem::Version.new(Fluent::VERSION) >= Gem::Version.new('0.14')
      Fluent::Test::Driver::Filter.new(FluentParseAuditLogFilter).configure(fluentd_conf)
    else
      Fluent::Test::FilterTestDriver.new(FluentParseAuditLogFilter, 'filter.test').configure(fluentd_conf)
    end
  end

  def driver_feed(driver, time, record, tag = 'filter.test')
    if Gem::Version.new(Fluent::VERSION) >= Gem::Version.new('0.14')
      driver.feed(tag, time, record)
    else
      driver.emit_with_tag(tag, record, time)
    end
  end

  def driver_filtered(driver)
    if Gem::Version.new(Fluent::VERSION) >= Gem::Version.new('0.14')
      driver.filtered
    else
      driver.filtered_as_array.map do |_, t, r|
        [t, r]
      end
    end
  end

  def flatten(hash)
    header = hash.fetch('header')
    body = hash.fetch('body')

    new_hash = (
      header.map {|k, v| ["header_#{k}", v] } +
      body.map {|k, v| ["body_#{k}", v] }
    ).to_h

    if new_hash.has_key?('body_msg')
      body_msg = new_hash.delete('body_msg')

      body_msg.each do |k, v|
        new_hash["body_msg_#{k}"] = v
      end
    end

    new_hash
  end
end
include FluentSpecHelper
