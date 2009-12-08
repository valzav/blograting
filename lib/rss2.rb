class Rss2
  attr_reader :path

  def initialize(path)
    @path = path
  end

  def open
    begin
      @doc = XML::Document.file(@path)
    rescue Exception => msg
      log.error("Rss2 - cannot open doc '#{@path}', exception '#{msg.to_s}'")
      return false
    end
    if @doc.nil? || @doc.root.nil?
      log.error("Rss2 - cannot open doc '#{@path}'")
      return false
    end
    return true
  end

  def link
    @doc.root.at('/rss/channel/link')
  end

  def title
    @doc.root.at('/rss/channel/title')
  end

  def description
    @doc.root.at('/rss/channel/description')
  end

  def image
    @doc.root.at('/rss/channel/image/url')
  end

  def each(fields)
    @doc.root.search('/rss/channel/item') do |item|
      begin
        item.register_default_namespace('ns')
      rescue
      end
      data = {}
      fields.each{|k,v| data[v] = item.at(k)}
      yield data
    end
  end

  private
  def decode_cdata(text)
    text = $1 if text && text =~ /^<\!\[CDATA\[(.*)\]\]>$/m
    return text
  end

  def htext(text)
    return nil if text.nil?
    HTMLEntities.decode_entities(decode_cdata(text))
  end

end