#!/usr/bin/env ruby

# starts a sinatra based web server that provides an interface to 
# your ticgit tickets
#
# author : K. Adam Christensen

%w(rubygems sinatra git ticgit haml gravatar).each do |dependency| 
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
$ticgit = TicGit.open('.')

before do
  @saved = $ticgit.config['list_options'].keys rescue []
end

get('/') do
  @title = "All Tickets"
  @tickets = $ticgit.ticket_list(:order => 'date.desc')
  haml :list
end

get('/tickets/state/:state') do
  @title = "#{params[:state].capitalize} Tickets"
  @tickets = $ticgit.ticket_list(:state => params[:state], :order => 'date.desc')
  haml :list
end

get('/tickets/tags/:tag') do
  @title = "#{params[:tag].capitalize} Tickets"
  @tickets = $ticgit.ticket_list(:tag => params[:tag], :order => 'date.desc')
  haml :list
end

get('/tickets/new') do
  @title = 'New Ticket'
  haml :new
end

post('/tickets') do
  title = params[:ticket_title].to_s.strip
  if title.size > 1
    tags = params[:ticket_tags].split(' ').map { |t| t.strip } rescue nil  
    comment = params[:ticket_comment].strip rescue nil
    comment = nil if comment.empty?
    t = $ticgit.ticket_new(title, {:comment => comment, :tags => tags})
    redirect '/tickets/' + t.ticket_id.to_s
  else
    redirect '/tickets/new'
  end
end

get('/tickets/:ticket') do
  @ticket = $ticgit.ticket_show(params[:ticket])
  @title = @ticket.title
  haml :show
end
