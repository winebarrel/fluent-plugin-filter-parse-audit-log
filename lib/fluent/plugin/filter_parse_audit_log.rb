require 'fluent_plugin_filter_parse_audit_log/version'
require 'audit_log_parser'

class FluentParseAuditLogFilter < Fluent::Filter
  Fluent::Plugin.register_filter('parse_audit_log', self)

  config_param :key, :string, default: 'message'
  config_param :flatten, :bool, default: false
  config_param :unhex, :bool, default: false
  config_param :unhex_keys, :array, default: ['*'], value_type: :string 
  config_param :unhex_min_length, :integer, default: 8

  def filter(tag, time, record)
    line = record[@key]
    return record unless line
    AuditLogParser.parse_line(line, flatten: @flatten, unhex: @unhex, unhex_keys: @unhex_keys, unhex_min_length: @unhex_min_length)
  rescue => e
    log.warn "failed to parse a audit log: #{line}", error_class: e.class, error: e.message
    log.warn_backtrace
    record
  end
end
