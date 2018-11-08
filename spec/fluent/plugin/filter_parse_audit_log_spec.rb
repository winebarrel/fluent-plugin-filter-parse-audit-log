RSpec.describe FluentParseAuditLogFilter do
  let(:driver) { create_driver }
  let(:today) { Time.parse('2015/05/24 18:30 UTC') }
  let(:time) { today.to_i }

  let(:audit_log) do
    {
      %q{type=SYSCALL msg=audit(1364481363.243:24287): arch=c000003e syscall=2 success=no exit=-13 a0=7fffd19c5592 a1=0 a2=7fffd19c4b50 a3=a items=1 ppid=2686 pid=3538 auid=500 uid=500 gid=500 euid=500 suid=500 fsuid=500 egid=500 sgid=500 fsgid=500 tty=pts0 ses=1 comm="cat" exe="/bin/cat" subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 key="sshd_config"} =>
      {"header"=>{"type"=>"SYSCALL", "msg"=>"audit(1364481363.243:24287)"},
      "body"=>
        {"arch"=>"c000003e",
        "syscall"=>"2",
        "success"=>"no",
        "exit"=>"-13",
        "a0"=>"7fffd19c5592",
        "a1"=>"0",
        "a2"=>"7fffd19c4b50",
        "a3"=>"a",
        "items"=>"1",
        "ppid"=>"2686",
        "pid"=>"3538",
        "auid"=>"500",
        "uid"=>"500",
        "gid"=>"500",
        "euid"=>"500",
        "suid"=>"500",
        "fsuid"=>"500",
        "egid"=>"500",
        "sgid"=>"500",
        "fsgid"=>"500",
        "tty"=>"pts0",
        "ses"=>"1",
        "comm"=>"\"cat\"",
        "exe"=>"\"/bin/cat\"",
        "subj"=>"unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023",
        "key"=>"\"sshd_config\""}},
      # ---
      %q{type=CWD msg=audit(1364481363.243:24287):  cwd="/home/shadowman"} =>
      {"header"=>{"type"=>"CWD", "msg"=>"audit(1364481363.243:24287)"},
      "body"=>{"cwd"=>"\"/home/shadowman\""}},
      # ---
      %q{type=PATH msg=audit(1364481363.243:24287): item=0 name="/etc/ssh/sshd_config" inode=409248 dev=fd:00 mode=0100600 ouid=0 ogid=0 rdev=00:00 obj=system_u:object_r:etc_t:s0} =>
      {"header"=>{"type"=>"PATH", "msg"=>"audit(1364481363.243:24287)"},
      "body"=>
        {"item"=>"0",
        "name"=>"\"/etc/ssh/sshd_config\"",
        "inode"=>"409248",
        "dev"=>"fd:00",
        "mode"=>"0100600",
        "ouid"=>"0",
        "ogid"=>"0",
        "rdev"=>"00:00",
        "obj"=>"system_u:object_r:etc_t:s0"}},
      # ---
      %q{type=DAEMON_START msg=audit(1363713609.192:5426): auditd start, ver=2.2 format=raw kernel=2.6.32-358.2.1.el6.x86_64 auid=500 pid=4979 subj=unconfined_u:system_r:auditd_t:s0 res=success} =>
      {"header"=>{"type"=>"DAEMON_START", "msg"=>"audit(1363713609.192:5426)"},
      "body"=>
        {"_message"=>"auditd start",
        "ver"=>"2.2",
        "format"=>"raw",
        "kernel"=>"2.6.32-358.2.1.el6.x86_64",
        "auid"=>"500",
        "pid"=>"4979",
        "subj"=>"unconfined_u:system_r:auditd_t:s0",
        "res"=>"success"}},
      # ---
      %q{type=USER_AUTH msg=audit(1364475353.159:24270): user pid=3280 uid=500 auid=500 ses=1 subj=unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023 msg='op=PAM:authentication acct="root" exe="/bin/su" hostname=? addr=? terminal=pts/0 res=failed'} =>
      {"header"=>{"type"=>"USER_AUTH", "msg"=>"audit(1364475353.159:24270)"},
      "body"=>
        {"user pid"=>"3280",
        "uid"=>"500",
        "auid"=>"500",
        "ses"=>"1",
        "subj"=>"unconfined_u:unconfined_r:unconfined_t:s0-s0:c0.c1023",
        "msg"=>
          {"acct"=>"\"root\"",
           "addr"=>"?",
           "exe"=>"\"/bin/su\"",
           "hostname"=>"?",
           "op"=>"PAM:authentication",
           "res"=>"failed",
           "terminal"=>"pts/0"}}},
    }
  end

  before do
    Timecop.freeze(today)
  end

  after do
    Timecop.return
  end

  let(:fluentd_conf) { {} }
  let(:driver) { create_driver(fluentd_conf) }

  context 'when audit.log are normal' do
    it 'can be parsed' do
      expect(driver.instance.log).to_not receive(:warn)

      driver.run do
        audit_log.keys.each do |line|
          driver_feed(driver, time, {'message' => line})
        end
      end

      actual = driver_filtered(driver)
      expected = audit_log.values.map {|record| [time, record] }
      expect(actual).to match_array expected
    end

    context 'when key is specified' do
      let(:key) { 'zapzapzap' }
      let(:fluentd_conf) { {'key' => key} }

      it 'can be parsed' do
        expect(driver.instance.log).to_not receive(:warn)

        driver.run do
          audit_log.keys.each do |line|
            driver_feed(driver, time, {key => line})
          end
        end

        actual = driver_filtered(driver)
        expected = audit_log.values.map {|record| [time, record] }
        expect(actual).to match_array expected
      end
    end

    context 'when flatten' do
      let(:fluentd_conf) { {'flatten' => true} }

      it 'can be parsed flatly' do
        expect(driver.instance.log).to_not receive(:warn)

        driver.run do
          audit_log.keys.each do |line|
            driver_feed(driver, time, {'message' => line})
          end
        end

        actual = driver_filtered(driver)
        expected = audit_log.values.map {|record| [time, flatten(record)] }
        expect(actual).to match_array expected
      end
    end
  end

  context 'when audit.log is invalid' do
    it 'warns' do
      expect(driver.instance.log).to receive(:warn).once
      invalid_log = audit_log.keys[0].delete('type=')

      driver.run do
        driver_feed(driver, time, {'message' => invalid_log})
        driver_feed(driver, time, {'message' => audit_log.keys[1]})
      end

      actual = driver_filtered(driver)
      expected = [[time, {'message' => invalid_log}], [time, audit_log.values[1]]]
      expect(actual).to match_array expected
    end
  end
end
