class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |meth_name|
  
      define_method("#{meth_name}=") do |change|
        instance_variable_set("@#{meth_name}", change)
      end 

      define_method("#{meth_name}") do 
        instance_variable_get("@#{meth_name}")
      end 

    end

  end 

end
