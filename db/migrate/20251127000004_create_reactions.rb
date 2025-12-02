# frozen_string_literal: true

class CreateReactions < ActiveRecord::Migration[7.2]
  def change
    create_table :reactions do |t|
      t.references :message, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :reaction_type, null: false
      t.timestamps
    end

    # Concurrency Safety: Database-level unique composite index
    # Why: This prevents race conditions where two simultaneous API requests could
    # insert duplicate reactions before the ActiveRecord validation fires.
    # The index enforces "one reaction per user per type per message" at the DB level,
    # ensuring data integrity even under high concurrency.
    # Works in conjunction with model validation (see Reaction model) for belt-and-suspenders approach.
    add_index :reactions, %i[message_id user_id reaction_type], unique: true,
                                                                name: "index_reactions_on_message_user_type"
  end
end
