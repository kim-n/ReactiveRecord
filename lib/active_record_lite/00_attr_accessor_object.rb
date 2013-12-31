class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |name|
      instance_name = "@#{name.to_s}".to_sym
      define_method(name){ self.instance_variable_get(instance_name) }
      define_method("#{name.to_s}=".to_sym){ |val| self.instance_variable_set(instance_name, val) }      
    end
  end
end
