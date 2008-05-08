# Variables
view_files = Dir.glob('views/*')

task :default => ['build/tiwatchtower']

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
end
