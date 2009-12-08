#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'

class String
  def get(regexp,ind=1)
    return regexp.match(to_s)[ind]
  end

  def to_float
    return empty? ? nil : Float(to_s)
  end
end

class SelectExpression
  attr_reader :type, :value, :next_expr, :regexp

  def initialize(value)
    case value[0].chr
    when '#', '.' then @type = :css
    when '~' then @type = :regexp
    when '$' then @type = :keyword
    else @type = :xpath
    end
    @type = :text if value == 'text'
    @value = value
    @regexp = Regexp.new(@value[1..-1],Regexp::MULTILINE) if @type == :regexp
    @regexp = Regexp.new("#{@value[1..-1]}[\s\:]*(.{1,1000})",Regexp::MULTILINE) if @type == :keyword
  end

  def set_next(next_expr)
    @next_expr = next_expr
  end

  def combine(expr)
    @value += "/#{expr.value}"
  end

  def run(node)
    return nil if node.nil?
    #puts "> #{node.class} :#{@type} : '#{@value}' #{node}"
    if @type == :css
      res = node.css(@value)
    elsif @type == :xpath
      res = node.xpath(@value)
    elsif @type == :keyword
      #puts "looking for keyword /#{@regexp}/"
      match = @regexp.match(node.to_html)
      res = match ? Nokogiri::HTML(match[1]).xpath('html/body/p').first : ""
    elsif @type == :text
      res = node.text
    else
      if @regexp
        match = @regexp.match(node.text)
        res = match ? match[1] : ""
      else
        res = node.to_html
      end
    end
    return "" if res.class == String && res.empty?
    res = res.first if res.class == Nokogiri::XML::NodeSet
    return @next_expr.run(res) if @next_expr
    return res.class == Nokogiri::XML::Element ? res.text.strip : res.to_s.strip
  end

end

module Nokogiri
  module XML
    class Node

      def get_attr(attr_name)
        res = attributes['src']
        return res ? res.to_s : nil
      end

      def select(path)
        return nil if path.nil?
        prev_expr = nil; first = nil
        path.split('/').each do |p|
          next if p.empty?
          cur_expr = SelectExpression.new(p)
          if first.nil?
            first = prev_expr = cur_expr
            next
          end

          if cur_expr.type == :xpath && prev_expr.type == :xpath
            prev_expr.combine(cur_expr)
            next
          end

          prev_expr.set_next(cur_expr)
          prev_expr = cur_expr

        end
        res = first ? first.run(self) : nil
        return res
      end

    end

  end
end

if $0 == __FILE__
  filename = ARGV[0]
  path = ARGV[1]
  puts "html parser test. file: #{filename}, select: #{path}"
  data = File.read(filename)
  doc = Nokogiri::HTML(data)
  puts doc.select(path)
end
