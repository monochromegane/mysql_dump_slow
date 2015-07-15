module MysqlDumpSlow
  class Counter
    attr_reader :abstract_query, :total_count, :total_query_time, :total_lock_time, :total_rows_sent, :user_hosts

    TIME_BASE_SEC = Time.utc(2000, 1, 1).to_i

    def initialize(abstract_query)
      @abstract_query = abstract_query
    end

    def count_up(log)
      count_up_query_time(log.query_time)
      count_up_lock_time(log.lock_time)
      count_up_rows_sent(log.rows_sent)
      count_up_user_host(log.user_host)
      count_up_counter
    end

    def total_user_host
      @user_hosts.size
    end

    def average_query_time
      total_query_time / total_count
    end

    def average_lock_time
      total_lock_time / total_count
    end

    def average_rows_sent
      total_rows_sent / total_count
    end

    def to_mysqldumpslow
      <<-EOS
Count: #{total_count}  Time=#{average_query_time/1000}s (#{total_query_time/1000}s)  Lock=#{average_lock_time/1000}s (#{total_lock_time/1000}s)  Rows=#{average_rows_sent} (#{total_rows_sent}),  #{ user_hosts.size == 1 ? user_hosts.first : user_hosts.size.to_s + 'hosts'}
  #{abstract_query}
      EOS
    end

    private

    def count_up_counter
      @total_count ||= 0
      @total_count +=  1
    end

    def count_up_query_time(query_time)
      @total_query_time ||= 0
      @total_query_time += time_to_ms(query_time - TIME_BASE_SEC)
    end

    def count_up_lock_time(lock_time)
      @total_lock_time ||= 0
      @total_lock_time += time_to_ms(lock_time - TIME_BASE_SEC)
    end

    def count_up_rows_sent(rows_sent)
      @total_rows_sent ||= 0
      @total_rows_sent += rows_sent
    end

    def count_up_user_host(user_host)
      @user_hosts ||= []
      @user_hosts << user_host unless @user_hosts.include?(user_host)
    end

    def time_to_ms(time)
      time.instance_eval { self.to_i * 1000 + (usec / 1000) }
    end
  end
end
