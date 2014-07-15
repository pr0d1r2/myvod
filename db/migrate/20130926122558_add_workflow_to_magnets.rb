class AddWorkflowToMagnets < ActiveRecord::Migration
  def change
    add_column :magnets, :workflow_state, :string
  end
end
