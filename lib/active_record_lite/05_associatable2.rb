require_relative '04_associatable'
require 'active_support/inflector'

module Associatable

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    
    self.send(:define_method, name.to_s) do
      source_options = through_options.model_class.assoc_options[source_name]
      
      source_table = source_options.table_name
      source_primary_key = source_options.primary_key
      source_foreign_key = source_options.foreign_key
      
      through_table = through_options.table_name
      through_primary_key = through_options.primary_key
      through_foreign_key = through_options.foreign_key
     
      through_key_value = self.send(through_foreign_key) 

      results = DBConnection.execute(<<-SQL, through_key_value )
        SELECT
          #{source_table}.*
        FROM
          #{through_table}
        JOIN
          #{source_table}
        ON
          #{through_table}.#{source_foreign_key} = #{source_table}.#{source_primary_key}
        WHERE
          #{through_table}.#{through_primary_key} = ?
      SQL
    
      source_options.model_class.new(results.first)
    end
  end
end
