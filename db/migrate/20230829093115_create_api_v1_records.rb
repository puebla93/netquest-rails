class CreateApiV1Records < ActiveRecord::Migration[7.0]
  def change
    create_table :api_v1_records do |t|

      t.timestamps

      t.string :title
      t.text :img
    end
  end
end
