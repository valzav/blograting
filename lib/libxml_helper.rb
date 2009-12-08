require "rubygems"
require "xml/libxml"

class XML::Node
  ##
  # Open up XML::Node from libxml and add convenience methods inspired
  # by hpricot.
  # (http://code.whytheluckystiff.net/hpricot/wiki/HpricotBasics)
  # Also:
  #  * provide better handling of default namespaces
 
  # an array of default namespaces to past into
  attr_accessor :default_namespaces
  
  def at(xpath)
    return nil if xpath.nil? || xpath.empty?
    res = self.find_first(xpath)
    return "" if res.nil?
    if res.class == LibXML::XML::Node
      return nil if res.children.size == 0
      res.children.each do |kid|
        value = kid.to_s.strip
        return value unless value.empty?
      end
      return nil
    elsif res.class == LibXML::XML::Attr
      return res.value
    else
      return res.to_s
    end
  end
 
  # find the array of child nodes matching the given xpath
  def search(xpath)
    results = self.find(xpath).to_a
    if block_given?
      results.each do |result|
        yield result
      end
    end
    return results
  end
 
  # alias for search
  def /(xpath)
    search(xpath)
  end
 
  # return the inner contents of this node as a string
  def inner_xml
    child.to_s
  end
 
  # alias for inner_xml
 def inner_html
    inner_xml
  end
 
  # return this node and its contents as an xml string
  def to_xml
    self.to_s
  end
 
  # alias for path
  def xpath
    self.path
  end
 
  # provide a name for the default namespace
  def register_default_namespace(name)
    self.namespaces.each do |n|
      if n.prefix == nil
        register_namespace("#{name}:#{n.href}")
        return
      end
    end
    raise "No default namespace found"
  end
 
  # register a namespace, of the form "foo:http://example.com/ns"
  def register_namespace(name_and_href)
    (@default_namespaces ||= []) <<name_and_href
  end
 
  def find_with_default_ns(xpath_expr, namespace=nil)
    find_base(xpath_expr, namespace || default_namespaces)
  end
 
  def find_first_with_default_ns(xpath_expr, namespace=nil)
    find_first_base(xpath_expr, namespace || default_namespaces)
  end
 
 
  alias_method :find_base, :find unless method_defined?(:find_base)
  alias_method :find, :find_with_default_ns
 
  alias_method :find_first_base, :find_first unless method_defined?(:find_first_base)
  alias_method :find_first, :find_first_with_default_ns
end
 
class String
  def to_libxml_doc
    xp = XML::Parser.new
    xp.string = self
    return xp.parse
  end
end

