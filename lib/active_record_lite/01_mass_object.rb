require_relative '00_attr_accessor_object.rb'

class MassObject < AttrAccessorObject
  def self.my_attr_accessible(*new_attributes)
    self.attributes.concat(new_attributes)
  end

  def self.attributes
    if self == MassObject
      raise 'must not call #attributes on MassObject directly'
    end
    @attributes ||= []
  end

  def initialize(params = {})
    params.each do |name, value|
      if self.class.attributes.include?(name.to_sym)
        instance_variable_set("@#{name}".to_sym, value)
      else
        raise "mass assignment to unregistered attribute '#{name}'"
      end
    end
  end
  
end