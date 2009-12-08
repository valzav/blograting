class TopRecord < Sequel::Model(DB)
  many_to_one :top
  many_to_one :post

  def before_save
    self.updated_at = DateTime.now
  end

end
