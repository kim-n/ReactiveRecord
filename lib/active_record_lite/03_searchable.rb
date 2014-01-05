require_relative 'db_connection'
require_relative '02_sql_object'

module Searchable
  def where(params)
    values = []
    where_line = []
    params.map do |key, value|
      values << [value]
      where_line << "#{key}=?"
    end
    
    where_line = where_line.join(" AND ")
    
    results = DBConnection.execute(<<-SQL, *values )
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_line}
    SQL
    
    parse_all(results)
  end
end

class SQLObject
  extend Searchable
end
