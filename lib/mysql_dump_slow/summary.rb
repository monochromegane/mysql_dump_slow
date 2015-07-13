module MysqlDumpSlow
  class Summary
    include Enumerable

    def initialize(logs)
      @logs = logs
      summarize
    end

    def sort_by(order)
      summary.sort_by do |counter|
        counter.send(order.to_sym) if counter.respond_to?(order.to_sym)
      end.reverse
    end

    def each(&block)
      summary.each(&block)
    end

    private

    def summarize
      @logs.find_each do |log|
        sql = Sql.mask(log.sql_text)
        counter = summary.find{|s| s.abstract_query == sql }
        counter ||= ( summary << Counter.new(sql) ).last
        counter.count_up(log)
      end
      @summary = sort_by(:average_query_time)
    end

    def summary
      @summary ||= []
    end
  end
end
