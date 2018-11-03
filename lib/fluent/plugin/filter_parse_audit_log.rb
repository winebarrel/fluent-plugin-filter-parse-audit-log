require 'fluent_plugin_filter_parse_audit_log/version'
require 'audit_log_parser'

module Fluent
  class ParseAuditLogFilter < Filter
    Plugin.register_filter('parse_audit_log', self)

    config_param :key, :string, :default => 'message'

    def filter(tag, time, record)
      line = record[@key]
      return record unless line

      AuditLogParser.parse_line(line)
    rescue => e
      log.warn "failed to parse a audit log: #{line}", error_class: e.class, error: e.message
      log.warn_backtrace
      record
    end
  end
end
