module MysqlDumpSlow
  class Sql
    def self.mask(sql)
      sql.gsub(/\b\d+\b/, 'N')
         .gsub(/\b0x[0-9A-Fa-f]+\b/, 'N')
         .gsub(/''/, "'S'")
         .gsub(/""/, '"S"')
         .gsub(/(\\')/, '')
         .gsub(/(\\")/, '')
         .gsub(/'[^']+'/, "'S'")
         .gsub(/"[^"]+"/, '"S"')
         .gsub(/"[^"]+"/, '"S"')
    end
  end
end
