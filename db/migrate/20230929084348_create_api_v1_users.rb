class CreateApiV1Users < ActiveRecord::Migration[7.0]
  def change
    create_table :api_v1_users do |t|

      t.timestamps

      t.string :email
      t.string :hashed_password
    end
  end
end
