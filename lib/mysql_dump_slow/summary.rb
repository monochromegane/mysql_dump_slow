module MysqlDumpSlow
  class Summary

    def initialize(logs)
      @logs = logs
    end

    def summarize
      @logs.each do |log|
        sql = parser.scan_str(log.sql_text).to_sql
        counter = summary.find{|s| s.abstract_query == sql }
        counter ||= ( summary << Counter.new(sql) ).last
        counter.count_up(log)
      end
      summary
    end

    private

    def summary
      @summary ||= []
    end

    def parser
      @parser ||= SQLParser::Parser.new
    end
  end
end
