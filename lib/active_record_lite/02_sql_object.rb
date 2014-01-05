require_relative 'db_connection'
require_relative '01_mass_object'
require 'active_support/inflector'

class MassObject
  def self.parse_all(results)
    results.map do |obj_hash|
      self.new(obj_hash)
    end
  end
end

class SQLObject < MassObject
  def self.table_name=(table_name)
    self.instance_variable_set(:@table_name, table_name)
  end

  def self.table_name
    default_name = self.name.underscore.pluralize
    self.instance_variable_get(:@table_name) || default_name
  end

  def self.all
    results = DBConnection.execute(<<-SQL )
      SELECT * FROM #{self.table_name}
    SQL
    
    parse_all(results)
  end

  def self.find(id)
    results = DBConnection.execute(<<-SQL, id )
      SELECT * FROM #{self.table_name} WHERE id = ?
    SQL
    
    parse_all(results)[0]
  end

  def insert
    col_names = self.class.attributes.join(", ")
    
    question_marks = (["?"] * self.class.attributes.count).join(",")
    
    results = DBConnection.execute(<<-SQL, *attribute_values )
      INSERT INTO #{self.class.table_name} (#{col_names}) VALUES (#{question_marks})
    SQL
    
    self.id = DBConnection.last_insert_row_id
  end

  def save
    unless self.id.nil?
      self.update
    else
      self.insert
    end
  end

  def update
    set_values = self.class.attributes.map {|attr| ["#{attr}=? "]}.join(",")
    
    question_marks = (["?"] * self.class.attributes.count).join(",")
    
    results = DBConnection.execute(<<-SQL,*attribute_values, id )
      UPDATE  #{self.class.table_name}
      SET #{set_values}
      WHERE #{self.class.table_name}.id = ?
    SQL

  end

  def attribute_values
    attributes = []
    col_names = self.class.attributes.join(", ")
    p col_names
    self.class.attributes.each do |attribute|
      attributes << self.send(attribute)
    end
    attributes
  end
end
