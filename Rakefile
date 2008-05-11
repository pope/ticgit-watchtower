require 'rubygems'
Gem::manage_gems
require 'rake/gempackagetask'

# Variables
view_files = Dir.glob('views/*')

spec = Gem::Specification.new do |s|
  s.platform              = Gem::Platform::RUBY
  s.name                  = 'ticgit-watchtower'
  s.version               = '0.1.0'
  s.author                = 'K. Adam Christensen'
  s.email                 = 'pope@shifteleven.com'
  s.summary               = 'Provide a nicer looking web interface for ticgit'
  s.files                 = ['build/tiwatchtower']
  s.has_rdoc              = false
  s.bindir                = 'build'
  s.homepage              = 'http://github.com/pope/ticgit-watchtower'
  s.executables << 'tiwatchtower'
  s.add_dependency 'git'
  s.add_dependency 'sinatra'
  s.add_dependency 'haml'
  s.add_dependency 'gravatar'
  s.add_dependency 'RedCloth'
  s.add_dependency('ticgit', '>=0.2.0')
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar            = true
end

#tasks
task :default => "pkg/#{spec.name}-#{spec.version}.gem"
task "pkg/#{spec.name}-#{spec.version}.gem" => ['build/tiwatchtower'] do
    puts "generated latest version"
end

directory 'build'

desc "Builds the single sinatra file for serving everything up"
file 'build/tiwatchtower' => ['build', 'watchtower.rb'].concat(view_files) do
  open('build/tiwatchtower', 'w') do |outfile|
    open('watchtower.rb') do |watchtower|
      while line = watchtower.gets
        outfile.puts line
      end
      outfile.puts "use_in_file_templates!"
      outfile.puts "__END__"
    end
    view_files.each do |view_file|
      outfile.puts "##" + File.basename(view_file, File.extname(view_file))
      open(view_file) do |infile|
        while line = infile.gets
          outfile.puts line
        end
      end
    end
  end
end

desc "Remove the build files"
task :clean do
  rm_rf 'build'
  rm_rf 'pkg'
end
