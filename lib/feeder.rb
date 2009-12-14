#!/usr/bin/env ruby
Dir.chdir(File.dirname(__FILE__) + "/../")
require "lib/libxml_helper.rb"
require "lib/daemon.rb"
require "lib/rss2"
require "./app.rb"

Dir.chdir(File.dirname(__FILE__) + "/../")

class Feeder < Daemon
  $AFTER_TASK_SLEEP_TIME = 3600

  def initialize
    super
    @fields_map = {}
    rss_fields = %w(author link title description pubDate)
    yablogs_fields = %w(commenters commenters24 comments comments24 links links24 links24weight linksweight visits24 ppb_username)
    rss_fields.each{|f| @fields_map[f]=f.to_sym}
    yablogs_fields.each{|f| @fields_map["yablogs:#{f}"]=f.to_sym}
  end

  def process_feed(feed)
    items = 0
    feed.each(@fields_map) do |i|
      #puts i.inspect
      i.merge!(:updated_at => DateTime.now)
      post = Post.find(:link => i[:link])
      if post
        post.update(i)
        puts "post '#{i[:link]}' updated"
      else
        post = Post.create(i)
        puts "post '#{i[:link]}' created"
      end
      items += 1
    end
    return items
  end

  def task
    @debug_mode = (@args[1] == "debug")
    if !@debug_mode
      for p in 1..5
        feed = Rss2.new("http://blogs.yandex.ru/entriesapi?p=#{p}",log)
        break unless feed.open
        items = process_feed(feed)
        break if items < 50
        puts "-------------- [#{items}] #{feed.path}"
      end
    else # debug mode - using local data
      for p in 1..3
        feed = Rss2.new("test_data/page#{p}.xml",log)
        puts "-------------- #{feed.path}"
        break unless feed.open
        process_feed(feed)
      end
    end

    Top.global.top_records_dataset.destroy

    Post.top(100).each do |post|
      post.download_details # TODO: move it from here to a special daemon process
      post.save
      r = TopRecord.create(:post => post, :top => Top.global)
      r.save
    end

    Top.global.save

  end

end

Feeder.new.run if $0 == __FILE__
