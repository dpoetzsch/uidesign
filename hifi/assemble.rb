#!/usr/bin/env ruby

require "fileutils"

template = File.read("template.html")
ITEMLIST = File.read("itemlist.html")
COMMENT_DIV = File.read("comment-div.html")

def convert_itemlist(il)
  # convert to list
  list = []
  cur = nil
  il.each_line { |l|
    if l[0] == "*"
      # type, name, comments list
      cur = [l.split[1], l.split[2..-1].join(" "), []]
      list.push cur
    elsif not cur.nil?
      cur[-1].push(l.strip.split(" -- "))
    end
  }
  
  html = ""
  list.each_with_index do |item, idx|
    t = ITEMLIST.gsub("$ITEMTYPE$", item[0])
    t.gsub!("$TITLE$", item[1])
    t.gsub!("$COMM-NUM$", item[2].length.to_s)
    t.gsub!("$ITEM-IDX$", idx.to_s)
    
    comments = ""
    item[2].each_with_index do |comment, cidx|
      comments += COMMENT_DIV.gsub("$TEXT$", comment[0]).gsub("$DATE$", comment[1])
    end
    t.gsub!("$COMMENTS-AREA$", comments)
    
    html += t
  end
  
  return html
end

def preproc_itemlist(str)
  l = str.split(/^=BEGIN ITEMLIST$/)
  if l.length > 1
    nstr = l[0]
    l[1..-1].each { |e|
      l2 = e.split(/^=END ITEMLIST$/)
      raise unless l2.length == 2
      
      nstr += convert_itemlist(l2[0])
      nstr += l2[1]
    }
    return nstr
  else
    return str
  end
end

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
    # preprocess value
    v = preproc_itemlist(v)
  
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

