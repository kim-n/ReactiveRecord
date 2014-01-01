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
  # Mixin Searchable here...
end


# TESTE

class Cat < SQLObject
  my_attr_accessor :id, :name, :owner_id
  my_attr_accessible :id, :name, :owner_id
end

class Human < SQLObject
  self.table_name = "humans"

  my_attr_accessor :id, :fname, :lname, :house_id
  my_attr_accessible :id, :fname, :lname, :house_id
end

Cat.where(:name => "Breakfast")