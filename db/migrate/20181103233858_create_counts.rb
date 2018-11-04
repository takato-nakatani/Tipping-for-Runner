class CreateCounts < ActiveRecord::Migration
  def change
    create_table :counts do |t|
      t.integer :number
      t.string :runner_line_id
      t.string :audience_line_id
      t.timestamps
    end
  end
end
