class Djia < ActiveRecord::Migration[5.2]
  def change
    create_table :djia do |t|
      t.datetime :date
      t.float :opening_price
      t.float :high_price
      t.float :low_price
      t.float :close_price
    end
  end
end
