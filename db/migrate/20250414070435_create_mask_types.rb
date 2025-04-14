class CreateMaskTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :mask_types do |t|
      t.string :name, null: false
      t.string :description
      t.string :color
      t.string :size

      t.timestamps
    end
  end
end