require "sql-parser"
module SQLParser 
  class SQLVisitor 
    def visit_DateTime(o);         "'S'"; end
    def visit_Date(o);             "'S'"; end
    def visit_String(o);           "'S'"; end
    def visit_ApproximateFloat(o);  'N';  end
    def visit_Float(o);             'N';  end
    def visit_Integer(o);           'N';  end
  end
end
