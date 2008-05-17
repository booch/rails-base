ENV["RAILS_ENV"] = "test"
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")
require 'spec/rails/story_adapter'

Dir[File.join(File.dirname(__FILE__), "steps/*.rb")].each do |file|
  require file
end

def run_story(file_name)
  run file_name.gsub(/(.*\/)(.*).rb/,'\1stories/\2.txt'), :type => RailsStory
end

# These allow exceptions to come through as opposed to being caught and hvaing non-helpful responses returned.
ActionController::Base.class_eval do
  def perform_action
    perform_action_without_rescue
  end
end

Dispatcher.class_eval do
  def self.failsafe_response(output, status, exception = nil)
    raise exception
  end
end


class String
  # Coverts a string found in the steps into a hash.  Example:
  # ISBN: '0967539854' and comment: 'I love this book' and rating: '4'
  #   => {"rating"=>"4", "isbn"=>"0967539854", "comment"=>"I love this book"}
  def to_hash_from_story
    self.split(/, and |, /).inject({}){ |hash_so_far, key_value| 
                                              key, value = key_value.split(":").map{ |v| v.strip.gsub(" ","_")}
                                              hash_so_far.merge(key.downcase => value.gsub("'",""))
                                            }
  end
end

def instantize(string)
  instance_variable_get("@#{string}")
end