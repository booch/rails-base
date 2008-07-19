#!/usr/bin/env ruby
require File.join(File.dirname(__FILE__).gsub(/stories(.*)/,"stories"),"helper")

with_steps_for :login, :webrat, :navigation, :database do
  run_story('stories/stories/login.txt')
end
