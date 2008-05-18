steps_for(:database) do

  Given "no $resource_class named '$name' exists" do |resource_class, name|
    klass = resource_class.classify.constantize
    klass.destroy_all(:name => name)
    klass.find_by_name(name).should be_nil
  end
  
  Then "a(n)? $resource_class named '$name' should exist" do |resource_class, name|
    resource = resource_class.classify.constantize.find_by_name(name)
    resource.should_not be_nil
    instance_variable_set("@#{resource_class.gsub(" ","_")}", resource)
  end
  
end
