class CreateAccounts < ActiveRecord::Migration[8.1]
  def change
    create_table :accounts do |t|
      t.string :name
      t.string :subdomain
      t.string :owner_name
      t.string :owner_email
      t.string :phone
      t.text :address
      t.string :city
      t.string :province
      t.string :plan
      t.boolean :active
      t.json :settings

      t.timestamps
    end
  end
end
