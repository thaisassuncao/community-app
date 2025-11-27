# frozen_string_literal: true

class CreateReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :reactions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reaction_type, null: false
      t.timestamps
    end

    add_index :reactions, %i[message_id user_id reaction_type], unique: true,
                                                                name: "index_reactions_on_message_user_type"
  end
end
