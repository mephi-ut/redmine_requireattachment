class AddIsPublicProjectToProject < ActiveRecord::Migration
  def self.up
    add_column :projects, :is_public_project, :boolean
  end

  def self.down
    remove_column :projects, :is_public_project
  end
end
