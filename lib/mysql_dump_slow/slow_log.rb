module MysqlDumpSlow
  class SlowLog
    def initialize(logs)
      @logs = logs
    end

    def find_each(options={})
      return @logs.each{ |log| yield log } unless active_record_relation?

      find_in_batches(options) do |records|
        records.each { |record| yield record }
      end
    end

    def find_in_batches(options={})
      return @logs.each{ |log| yield log } unless active_record_relation?

      batch_order = options[:batch_order] || :start_time
      batch_size  = options[:batch_size]  || 1000

      relation = @logs
      relation = relation.reorder(batch_order).limit(batch_size)
      records  = relation.to_a

      while records.any?
        records_size = records.size
        primary_key_offset = records.last.start_time

        yield records

        break if records_size < batch_size

        records = relation.where("#{batch_order} > ?", primary_key_offset).to_a
      end
    end

    private

    def active_record_relation?
      defined?(ActiveRecord::Relation) && @logs.is_a?(ActiveRecord::Relation)
    end
  end
end
