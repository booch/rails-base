class String
  def trim(chars = '\s')
    self.gsub(/^[#{chars}]+|[#{chars}]+$/)
  end
  def ltrim(chars = '\s')
    self.gsub(/^[#{chars}]+/, '')
  end
  def rtrim(chars = '\s')
    self.gsub(/[#{chars}]+$/, '')
  end
end

steps_for(:navigation) do

  Given /I am logged out/ do
    visits 'session/logout'
  end

  When /(I|) (visit|go to) '$page'/ do |actor, action, page|
    visits page
  end


  When /(I )?go to the home page/ do
    get "/"
  end

  When /(I )?go to $path/ do |path|
    get path
  end
  
  Then /(I )?should see the $resource show page/ do |resource|
    response.should render_template("#{resource.gsub(" ","_").pluralize}/show")
  end


  Then 'I should end up at the $page page' do |page|
    page_map = {'home' => '/index/index', 'login' => '/session/new'}
    page = page_map.values_at(page).first || page
    page = page.ltrim('/')
    response.should render_template(page)
  end
    
  # Pass the params as such: ISBN: '0967539854' and comment: 'I love this book' and rating: '4'
  # this matcher will post to the resourcese default create action
  When /(I )?submit $a_or_an $resource with $attributes/ do |a_or_an, resource, attributes|
    post_via_redirect "/#{resource.downcase.pluralize}", {resource.downcase => attributes.to_hash_from_story}
  end
  
  Then "page should include text: $text" do |text|
    response.should have_text(/#{text}/)
  end
  
  Then "page should include a notice '$notice_message'" do |notice_message|
    response.should have_tag("div.notice", notice_message)
  end
  
  Then "page should have the $resource's $attributes" do |resource, attributes|
    actual_resource = instantize(resource)
    attributes.split(/, and |, /).each do |attribute|
      response.should have_text(/#{actual_resource.send(attribute.strip.gsub(" ","_"))}/)
    end
  end
  
end
