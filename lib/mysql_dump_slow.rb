require "mysql_dump_slow/version"
require "mysql_dump_slow/counter"
require "mysql_dump_slow/sql"
require "mysql_dump_slow/slow_log"
require "mysql_dump_slow/summary"

module MysqlDumpSlow
  def self.summarize(slow_logs)
    Summary.new(slow_logs)
  end
end
