class CreateBooksAuthorsTable < Sequel::Migration

  def up
    create_table(:platforms) do
      primary_key :id
      String :name, :unique=>true
      String :make
      String :link
      String :logo
      String :url_regexp
      String :userpic
      String :selector_post
      String :selector_avatar
    end

    create_table(:users) do
      primary_key :id
      String :name
      String :email, :unique=>true
    end

    create_table(:tops) do
      primary_key :id
      Fixnum :user_id
      String :name
      DateTime :updated_at
      index :user_id
    end

   create_table(:top_records) do
      primary_key :id
      Fixnum :top_id
      Fixnum :post_id
      DateTime :updated_at
      index :top_id
      index :post_id
   end

    create_table(:posts) do
      primary_key :id
      String :link, :unique=>true
      String :author
      String :title
      String :description
      DateTime :pubDate
      Fixnum :commenters
      Fixnum :commenters24
      Fixnum :comments
      Fixnum :comments24
      Fixnum :links
      Fixnum :links24
      Float :links24weight
      Float :linksweight
      Fixnum :visits24
      String :ppb_username
      DateTime :updated_at
      Text :text
      Fixnum :platform_id
      index :link
      index :visits24
      index :platform_id
    end
  end

  def down
    drop_table(:platforms)
    drop_table(:tops)
    drop_table(:top_records)
    drop_table(:posts)
    drop_table(:users)
  end
end
