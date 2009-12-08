require 'lib/html_parser'
require 'curl'
require 'iconv'

class Platform < Sequel::Model(DB)

  def belongs_to_platform?(post_url)
    if @urlregexp.nil?
      return false unless url_regexp
      @urlregexp = Regexp.new(url_regexp,1)
    end
    return !!@urlregexp.match(post_url)
  end

  def post_preview(post_url)
    return '' if selector_post.nil? || selector_post.empty?
    doc = get_post_html(post_url)
    return '' if doc.nil?
    selector_post.split('; ').each do |s|
      preview = cut_post_preview(doc,s)
      return preview unless preview.empty?
    end
    return ''
  end

  def get_post_html(post_url)
    if post_url =~ /^http:\/\//
      curl = Curl::Easy.new
      curl.headers["User-Agent"] = "blogovod-1.0"
      curl.headers["Accept-Charset"] = "UTF-8, windows-1251"
      curl.url = post_url
      curl.perform
      data = curl.body_str
      if curl.header_str =~ /charset=[\w\-]+1251/mi
        data = Iconv.conv("UTF-8", "CP1251", data)
      end
    else # local file for testing purpose
      data = File.read(post_url)
    end
    return Nokogiri::HTML(data)
  rescue Exception => ex
    puts "Can't retrieve post '#{post_url}': #{ex.to_s}"
    return nil
  end

  CUT_LEN1 = 500
  CUT_LEN2 = 600
  CUT_LEN3 = 700

  def cut_post_preview(doc,selector)
    t = doc.select(selector)
    return "" if t.nil?
    # now let's cut it in a smart way
    last_tag = ""
    in_tag = false
    counter = 0
    out = ""
    for i in 0...t.length
      # TODO: utf-8 support
      c = t[i].chr
      if c == '<'
        in_tag = true
        last_tag = ""
      elsif c == '>'
        in_tag = false
        out += "<#{last_tag}>" if last_tag =~ /^\/?[ibpa]{1}(\s|$)/
        break if counter >= CUT_LEN1 && last_tag =~ /\//
      else
        if in_tag
          last_tag += c
        else
          counter += 1
          out += c
          break if counter >= CUT_LEN3 && c == " "
          break if counter >= CUT_LEN2 && (c == "." || c == ",")
        end
      end
    end
    #puts [i,t.length-1]
    return out
  end
end
