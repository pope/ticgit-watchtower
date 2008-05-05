#!/usr/bin/env ruby

# starts a sinatra based web server that provides an interface to 
# your ticgit tickets
#
# author : K. Adam Christensen (pope@shifteleven.com)

%w(rubygems sinatra git ticgit haml).each do |dependency| 
  begin
    require dependency
  rescue LoadError => e
    puts "You need to install #{dependency} before we can proceed"
  end
end

get('/screen.css') do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :screen
end

$yui_version = '2.5.1'

before do
  @saved = nil #$ticgit.config['list_options'].keys rescue []
end

get('/') do
  haml :index, :locals => { :title => "Hello" }
end
