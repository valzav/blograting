class Top < Sequel::Model(DB)
  many_to_one :user
  one_to_many :top_records
  many_to_many :posts, :join_table => "top_records", :order => :visits24.desc

  def before_save
    self.updated_at = DateTime.now
  end

  @@global = nil

  def self.global
    return @@global if @@global
    @@global = self[:name => "global"]
    return @@global if @@global
    @@global = self.create(:name => "global")
    @@global.save
    return @@global
  end

  
end
