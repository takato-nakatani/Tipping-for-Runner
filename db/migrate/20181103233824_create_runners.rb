class CreateRunners < ActiveRecord::Migration
  def change
    create_table :runners do |t|
      t.string :name
      t.integer :number
      t.integer :marathon_id
      t.string :runner_line_id
      t.timestamps
    end
  end
end
