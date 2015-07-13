require 'test_helper'

class MysqlDumpSlowTest < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::MysqlDumpSlow::VERSION
  end

  def test_counter
    query = 'SELECT * FROM T'
    output = <<-EOS
Count: 2  Time=10s (20s)  Lock=20s (40s)  Rows=300 (600),  host_1
  SELECT * FROM T
    EOS

    counter = ::MysqlDumpSlow::Counter.new(query)
    log = OpenStruct.new(
      query_time: Time.local(2000, 1, 1, 0, 0, 10),
      lock_time:  Time.local(2000, 1, 1, 0, 0, 20),
      rows_sent:  300,
      user_host:  'host_1'
    )
    counter.count_up(log)
    counter.count_up(log)

    assert_equal query,      counter.abstract_query
    assert_equal 2,          counter.total_count
    assert_equal 20000,     counter.total_query_time
    assert_equal 10000,     counter.average_query_time
    assert_equal 40000,     counter.total_lock_time
    assert_equal 20000,     counter.average_lock_time
    assert_equal 600,        counter.total_rows_sent
    assert_equal 300,        counter.average_rows_sent
    assert_equal ['host_1'], counter.user_hosts
    assert_equal output,     counter.to_mysqldumpslow
  end

  def test_summary
    summary = ::MysqlDumpSlow::Summary.new(slow_logs)

    # group by abstract_query
    assert_equal 2, summary.count

    # masking values
    expect_abstract_queries = [
      'SELECT * FROM T WHERE F1 = N',
      "SELECT * FROM T WHERE F1 = N AND F2 = 'S'"
    ]
    summary.each_with_index do |counter, i|
      assert_equal expect_abstract_queries[i], counter.abstract_query
    end
  end

  def test_summary_sort_by
    summary = ::MysqlDumpSlow::Summary.new(slow_logs).sort_by(:rows_sent)

    # sort by rows_sent
    expect_abstract_queries = [
      "SELECT * FROM T WHERE F1 = N AND F2 = 'S'",
      'SELECT * FROM T WHERE F1 = N',
    ]
    summary.each_with_index do |counter, i|
      assert_equal expect_abstract_queries[i], counter.abstract_query
    end
  end

  def slow_logs
    logs = [
      # query1
      OpenStruct.new(
        sql_text:   'SELECT * FROM T WHERE F1 = 1',
        query_time: Time.local(2000, 1, 1, 0, 0, 10),
        lock_time:  Time.local(2000, 1, 1, 0, 0, 20),
        rows_sent:  300,
        user_host:  'host_1'
      ),
      # query1
      OpenStruct.new(
        sql_text:   'SELECT * FROM T WHERE F1 = 1',
        query_time: Time.local(2000, 1, 1, 0, 0, 30),
        lock_time:  Time.local(2000, 1, 1, 0, 0, 20),
        rows_sent:  300,
        user_host:  'host_1'
      ),
      # query2
      OpenStruct.new(
        sql_text:   "SELECT * FROM T WHERE F1 = 1 AND F2 = 'a'",
        query_time: Time.local(2000, 1, 1, 0, 0, 10),
        lock_time:  Time.local(2000, 1, 1, 0, 0, 20),
        rows_sent:  500,
        user_host:  'host_1'
      ),
    ]

    # mock active record find_each method
    def logs.find_each(&block)
      each(&block)
    end
    logs
  end
end
