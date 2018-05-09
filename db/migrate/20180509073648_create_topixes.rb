class CreateTopixes < ActiveRecord::Migration[5.1]
  def change
    create_table :topixes do |t|
      t.date :date
      t.decimal :opening_price, precision: 10, scale: 2
      t.decimal :high_price, precision: 10, scale: 2
      t.decimal :low_price, precision: 10, scale: 2
      t.decimal :close_price, precision: 10, scale: 2

      t.timestamps
    end
  end
end
