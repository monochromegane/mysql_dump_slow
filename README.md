# MysqlDumpSlow

A library to summarize MySQL slow\_log records in Ruby.

## Usage

### Summarize and print result.

```ruby
# Getting slow logs by using ActiveRecord for mysql.slow_log.
logs = SlowLog.all

# Summarize slow logs
summary = MysqlDumpSlow.summarize(logs)
summary.each do |conter|
  # counter provides printer that same as mysqldumpslow command.
  counter.to_mysqldumpslow
  # => Count: 2  Time=100s (200s)  Lock=200s (400s)  Rows=300 (600),  2hosts
  #      SELECT * FROM T
end
```

### Use total/average getter

```ruby
# counter provides every total/avg getter. See also test codes.
counter.total_query_time   # => 100000
counter.average_query_time # => 100000
```

- total\_count
- [ total | average ]\_query\_time
- [ total | average ]\_lock\_time
- [ total | average ]\_rows\_set
- user\_hosts

### ActiveRecord

MysqlDumpSlow.summarize require ActiveRecord for mysql.slow\_log table.
An example is the following.

```ruby
class SlowLog < ActiveRecord::Base
  self.table_name = 'slow_log'

  def self.new_connection_info
    connection_info = self.configrations[Rails.env]
    connection_info["database"] = "mysql"
    connection_info
  end

  establish_connection new_connection_info
end
```

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'mysql_dump_slow'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install mysql_dump_slow

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/monochromegane/mysql\_dump\_slow. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

