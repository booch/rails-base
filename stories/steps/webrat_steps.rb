steps_for(:webrat) do


  When "I click on the '$link' link" do |link|
    clicks_link link
  end

  When "(I )?fill in $field with '$value'" do |field, value|
    fills_in field, :with => value
  end  

  When "enter '$value' in the $field field" do |value, field|
    fills_in field, :with => value
  end  

  When "(I )?select $field as '$option'" do |field, option|
    selects option, :from => field
  end
  
  When "(I )?check $checkbox" do |checkbox|
    checks checkbox
  end
  
  When "click on the '$button' button" do |button|
    clicks_button button
  end
    
end