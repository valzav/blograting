class Post < Sequel::Model(DB)
  many_to_one :platform

  def before_save
    Platform.all do |pl|
      if pl.belongs_to_platform?(link)
        self.platform_id = pl.id
        break
      end
    end
  end

  def download_details
    return if !self.text.nil? || self.platform.nil?
    self.text = self.platform.post_preview(link)
    #puts "\ndownoloaded details for post #{link} '#{title}'\n#{text}"
  end

  def self.top(top_num)
    now = DateTime.now
    Post.filter{|p| p.updated_at > (now-1)}.filter{|p| p.pubDate>(now-3)}.order(:visits24.desc).limit(top_num)
  end
end
