require_relative '04_associatable'
require 'active_support/inflector'

module Associatable

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    
    self.send(:define_method, name.to_s) do
      source_options = through_options.model_class.assoc_options[source_name]
      
      join_line = "#{source_options.table_name} ON #{through_options.table_name}.#{source_options.foreign_key} = #{source_options.table_name}.id"

      where_line = "#{through_options.table_name}.id = ?"
     
      results = DBConnection.execute(<<-SQL, self.send(through_name).id )
        SELECT
          #{source_options.table_name}.*
        FROM
          #{through_options.table_name}
        JOIN
          #{join_line}
        WHERE
          #{where_line}
      SQL
    
      source_options.model_class.new(results.first)
    end
  end
end
