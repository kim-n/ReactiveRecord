require_relative '03_searchable'
require 'active_support/inflector'

class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key,
  )

  def model_class
    self.class_name.constantize
  end

  def table_name
    model_class.table_name
  end
end

class BelongsToOptions < AssocOptions
  
  def initialize(name, options = {})
    self.foreign_key = options[:foreign_key] || "#{name.to_s}_id".to_sym
    self.primary_key = options[:primary_key] || :id
    self.class_name = options[:class_name] || "#{name.to_s.capitalize}"
  end
end

class HasManyOptions < AssocOptions
  
  def initialize(name, self_class_name, options = {})
    self.class_name = options[:class_name] || "#{name.to_s.capitalize.singularize}"
    self.foreign_key = options[:foreign_key] || "#{self_class_name.downcase}_id".to_sym
    self.primary_key = options[:primary_key] || :id
  end
end

module Associatable
  def belongs_to(name, options = {})
    
    opts = BelongsToOptions.new(name, options)
    self.assoc_options[name] = opts
    foreign_key = opts.foreign_key
    self.send(:define_method, name.to_s) do
      opts.model_class.where( :id => self.send(foreign_key)).first
    end
    
  end

  def has_many(name, options = {})
    opts = HasManyOptions.new(name, self.name , options)
    foreign_key = opts.foreign_key
    self.send(:define_method, name.to_s) do
      opts.model_class.where( foreign_key => self.id)
    end
    
  end

  def assoc_options
    @assoc_options ||= {}
  end
end

class SQLObject
  extend Associatable
end
