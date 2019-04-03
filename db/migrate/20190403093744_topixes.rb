class Topixes < ActiveRecord::Migration[5.2]
  def change
    create_table :topixes do |t|
      t.datetime :date
      t.float :opening_price
      t.float :high_price
      t.float :low_price
      t.float :close_price
    end
  end
end
