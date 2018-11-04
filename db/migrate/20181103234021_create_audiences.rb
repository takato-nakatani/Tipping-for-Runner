class CreateAudiences < ActiveRecord::Migration
  def change
    create_table :audiences do |t|
      t.string :audience_line_id
      t.timestamps
    end
  end
end
