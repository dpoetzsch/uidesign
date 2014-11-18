#!/usr/bin/env ruby

require "fileutils"

template = File.read("template.html")
ITEMLIST = File.read("itemlist.html")
ITEMLIST_COMMENT = File.read("itemlist-comment.html")
COMMENT_DIV = File.read("comment-div.html")
BREADCRUMP = File.read("breadcrump.html")
BREADCRUMP_ITEM = File.read("breadcrump-item.html")
METAINFO = File.read("meta-info.html")

def parse_item(item)
  type = item.split[0]
  name = item.split[1..-1].join(" ")
  url = ""
  
  if name =~ /^(.+) = (.+?)$/
    name = $1
    url = $2
  end
  
  return [type, name, url]
end

def convert_breadcrump(bc)
  items = []
  bc.split(" / ").each do |item|
    type, name, url = parse_item(item)
    
    html = BREADCRUMP_ITEM.gsub("$TYPE$", type)
    html.gsub!("$NAME$", name)
    html.gsub!("$URL$", url)
    items.push(html)
  end
  return BREADCRUMP.gsub("$PATH$", items.join(" / "))
end

def convert_itemlist(il)
  # convert to list
  list = []
  cur = nil
  il.each_line { |l|
    if l[0..1] == "* "
      # type, name, comments list
      type, name, url = parse_item(l[2..-1])
      cur = [type, name, url, []]
      list.push cur
    elsif not cur.nil?
      cur[-1].push(l.strip.split(" -- "))
    end
  }
  
  html = ""
  list.each_with_index do |item, idx|
    if item[0] == "comment"
      t = ITEMLIST_COMMENT.clone
    else
      t = ITEMLIST.clone
    end
    t.gsub!("$ITEMTYPE$", item[0])
    t.gsub!("$TITLE$", item[1])
    t.gsub!("$URL$", item[2])
    t.gsub!("$COMM-NUM$", item[-1].length.to_s)
    t.gsub!("$ITEM-IDX$", idx.to_s)
    
    comments = ""
    item[-1].each_with_index do |comment, cidx|
      comments += COMMENT_DIV.gsub("$TEXT$", comment[0]).gsub("$DATE$", comment[1])
    end
    t.gsub!("$COMMENTS-AREA$", comments)
    
    html += t
  end
  
  return html
end

def convert_metainfo(mi)
  lines = mi.strip.split("\n")
  
  html = METAINFO.gsub("$UPLOADER$", lines[0])
  html.gsub!("$DATE$", lines[1])
  
  comments = ""
  lines[2..-1].each_with_index do |comment, cidx|
    text, date = comment.split(" -- ")
    comments += COMMENT_DIV.gsub("$TEXT$", text).gsub("$DATE$", date)
  end
  html.gsub!("$COMMENTS-AREA$", comments)
  
  return html
end

def preproc(str, key)
  l = str.split(/^=BEGIN #{key}$/)
  if l.length > 1
    nstr = l[0]
    l[1..-1].each { |e|
      l2 = e.split(/^=END #{key}$/)
      raise unless l2.length == 2
      
      nstr += yield(l2[0])
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
    v = preproc(v, "BREADCRUMP") { |bc| convert_breadcrump(bc) }
    v = preproc(v, "ITEMLIST") { |il| convert_itemlist(il) }
    v = preproc(v, "META-INFO") { |il| convert_metainfo(il) }
  
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

