#!/usr/bin/env ruby

require "fileutils"

template = File.read("template.html")

begin
  FileUtils.mkdir("output")
rescue
end

Dir["content/*.html"].each { |f|
  c = File.read(f)
  
  repl_map = {}
  
  cur = nil
  c.each_line { |l|
    if l.chomp =~ /^\$.+\$$/
      cur = l.chomp
      repl_map[cur] = ""
    elsif not cur.nil?
      repl_map[cur] += l
    end
  }
  
  html = template.clone
  repl_map.each { |k, v|
    html.gsub!(k, v)
  }
  
  # remove remaining $$
  html.gsub!(/\$.+\$/, "")
  
  fname = File.join("output", File.basename(f))
  puts "Creating #{fname}..."
  File.open(fname, "w") { |f|
    f.write html
  }
}

