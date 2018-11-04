# fluent-plugin-filter-parse-audit-log

Fluentd Filter Plugin to parse [linux's audit log](https://github.com/linux-audit/audit-documentation/wiki).

[![Gem Version](https://badge.fury.io/rb/fluent-plugin-filter-parse-audit-log.svg)](http://badge.fury.io/rb/fluent-plugin-filter-parse-audit-log)
[![Build Status](https://travis-ci.org/winebarrel/fluent-plugin-filter-parse-audit-log.svg?branch=master)](https://travis-ci.org/winebarrel/fluent-plugin-filter-parse-audit-log)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'fluent-plugin-filter-audit-log'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install fluent-plugin-filter-audit-log

## Configuration

```
@type parse_audit_log
#key message
```

## Example

```
<source>
  @type forward
</source>

<filter audit.log>
  @type parse_audit_log
</filter>

<match audit.log>
  @type stdout
</match>
```

```sh
echo '{"message":"type=SYSCALL msg=audit(1364481363.243:24287): arch=c000003e syscall=2 success=no exit=-13 a0=7fffd19c5592 a1=0 a2=7fffd19c4b50 a3=a items=1 ppid=2686 pid=3538 auid=500 uid=500 gid=500 euid=500 suid=500 fsuid=500 egid=500 sgid=500 fsgid=500 tty=pts0 ses=1 comm=\"cat\" exe=\"/bin/cat\" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key=\"sshd_config\""}' | fluent-cat -t audit.log
```

```json
2018-11-04 11:48:05.000000000 +0900 audit.log: {"header":{"type":"SYSCALL","msg":"audit(1364481363.243:24287)"},"body":{"arch":"c000003e","syscall":"2","success":"no","exit":"-13","a0":"7fffd19c5592","a1":"0","a2":"7fffd19c4b50","a3":"a","items":"1","ppid":"2686","pid":"3538","auid":"500","uid":"500","gid":"500","euid":"500","suid":"500","fsuid":"500","egid":"500","sgid":"500","fsgid":"500","tty":"pts0","ses":"1","comm":"\"cat\"","exe":"\"/bin/cat\"","subj":"unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023","key":"\"sshd_config\""}}
```

## Related Links

* https://github.com/winebarrel/audit_log_parser
* [7.6. Understanding Audit Log Files - Red Hat Customer Portal](https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/security_guide/sec-understanding_audit_log_files)
* [SPEC Writing Good Events · linux-audit/audit-documentation Wiki](https://github.com/linux-audit/audit-documentation/wiki/SPEC-Writing-Good-Events)
