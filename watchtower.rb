#!/usr/bin/env ruby

# starts a sinatra based web server that provides an interface to 
# your ticgit tickets
#
# author : K. Adam Christensen

%w(rubygems sinatra git ticgit haml gravatar set).each do |dependency|
  begin
    require dependency
  rescue LoadError => e
    puts "You need to install #{dependency} before we can proceed"
  end
end

unless ARGV[0]
  $stderr.puts "You must specify a path to a git repository"
  Process.exit
end

$ticgit = TicGit.open(ARGV[0].chomp)
$yui_version = '2.5.1'

get('/screen.css') do
  header 'Content-Type' => 'text/css; charset=utf-8'
  sass :screen
end

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

get('/tickets/saved_views/:view') do
  @tickets = $ticgit.ticket_list(:saved => params[:saved_view])
  @title = "#{params[:view].capitalize} View"
  haml :list
end

get('/tickets/new') do
  @title = 'New Ticket'
  haml :new
end

post('/tickets') do
  title = params[:ticket_title].to_s.strip
  if title.size > 1
    tags = params[:ticket_tags].split(',').map { |t| t.strip } rescue nil
    comment = params[:ticket_comment].strip rescue nil
    comment = nil if comment.empty?
    t = $ticgit.ticket_new(title, {:comment => comment, :tags => tags})
    redirect '/tickets/' + t.ticket_id.to_s
  else
    redirect '/tickets/new'
  end
end

get('/tickets/:id') do
  @ticket = $ticgit.ticket_show(params[:id])
  @title = @ticket.title
  haml :show
end

put('/tickets/:id') do

  @ticket = $ticgit.ticket_show(params[:id])

  comment = params[:ticket_comment].strip rescue ""
  unless comment.empty?
    $ticgit.ticket_comment(comment, params[:id])
  end

  $ticgit.ticket_assign(params[:ticket_assigned], params[:id])

  original_tags = @ticket.tags.to_set
  updated_tags = params[:ticket_tags].split(',').map { |t| t.strip }.to_set rescue Set.new

  tags_to_remove = (original_tags - updated_tags).to_a.join(',')
  $ticgit.ticket_tag(tags_to_remove, params[:id], :remove => true)

  tags_to_add = (updated_tags - original_tags).to_a.join(',')
  $ticgit.ticket_tag(tags_to_add, params[:id])

  $ticgit.ticket_change(params[:ticket_state], params[:id])

  redirect "/tickets/#{@ticket.ticket_id}"
end
