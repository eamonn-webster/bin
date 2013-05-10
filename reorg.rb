require 'FileUtils'

root = '/Users/eweb/accounts'
folder = 'java'
  begin
    Dir.new("#{root}/#{folder}").each do |f|
  begin
    if File.directory?("#{root}/#{folder}/#{f}")
      Dir.chdir("#{root}/#{folder}/#{f}")
      Dir.new('.').each do |ff|
        if ff =~ /[a-z][a-z][a-z][0-9][0-9]\.(cbk|dry|bbb|slt)/
          #puts( "FileUtils.move(#{ff}, #{ff.capitalize})" )
          `git mv #{ff} #{ff}.tmp`
          `git mv #{ff}.tmp #{ff.capitalize}`
        end
      end
    end
  #rescue


  #  puts "oops #{$!}"
  end
end

ensure
Dir.chdir(root)
end
