module MysqlDumpSlow
  class Summary

    def initialize(logs)
      @logs = logs
    end

    def summarize
      @logs.each do |log|
        sql = parser.scan_str(log.sql_text).to_sql
        summary[sql] = Counter.new unless summary.key?(sql)
        summary[sql].count_up(log)
      end
      summary
    end

    private

    def summary
      @summary ||= {}
    end

    def parser
      @parser ||= SQLParser::Parser.new
    end
  end
end
