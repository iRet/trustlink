class CreateTrustlinkStorage < ActiveRecord::Migration
  def change
    create_table :trustlink_configs do |t|
      t.string :name
      t.string :value
    end

    create_table :trustlink_links do |t|
      t.string :page
      t.string :anchor
      t.string :text
      t.string :url
    end
  end
end
