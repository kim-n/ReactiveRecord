require_relative '04_associatable'
require 'active_support/inflector'

# Phase V
module Associatable
  # Remember to go back to 04_associatable to write ::assoc_options

  def has_one_through(name, through_name, source_name)
    through_options = self.assoc_options[through_name]
    
    # p "SELF1, #{self}"
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
    
      res = source_options.model_class.new(results.first)
    end
  end
end

class Cat < SQLObject
  my_attr_accessible :id, :name, :owner_id
  my_attr_accessor :id, :name, :owner_id

  belongs_to :human, :foreign_key => :owner_id
  has_one_through :home, :human, :house
end

class Human < SQLObject
  self.table_name = "humans"

  my_attr_accessible :id, :fname, :lname, :house_id
  my_attr_accessor :id, :fname, :lname, :house_id

  has_many :cats, :foreign_key => :owner_id
  belongs_to :house
  
end

class House < SQLObject
  my_attr_accessible :id, :address, :house_id
  my_attr_accessor :id, :address, :house_id

  has_many :humans
end

  cat = Cat.find(1)
  house = cat.home
  # puts house
  # puts house.class
  # expect(house).to be_instance_of(House)
  # expect(house.address).to eq("26th and Guerrero")
  