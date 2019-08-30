class AttrAccessorObject
  def self.my_attr_accessor(*names)
    names.each do |meth_name|
      define_method(meth_name) do |change = meth_name|
        if change == meth_name
          instance_method_get(meth_name)
        else 
          instance_method_set(meth_name, change)
        end 
      end 
    end 

    # names.each do |meth_name| 
    #   define_method(meth_name) do 
    #     instance_method_get(meth_name)
    #   end 
    # end 
  end
end
