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
    # ...
  end

  def self.find(id)
    # ...
  end

  def insert
    # ...
  end

  def save
    # ...
  end

  def update
    # ...
  end

  def attribute_values
    # ...
  end
end


class Cat < SQLObject
  my_attr_accessor :id, :name, :owner_id
  my_attr_accessible :id, :name, :owner_id
end

class Human < SQLObject
  self.table_name = "humans"

  my_attr_accessor :id, :fname, :lname, :house_id
  my_attr_accessible :id, :fname, :lname, :house_id
end

p Cat.table_name

