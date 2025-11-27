# frozen_string_literal: true

class CreateMessages < ActiveRecord::Migration[7.2]
  def change
    create_table :messages do |t|
      t.references :user, null: false, foreign_key: true
      t.references :community, null: false, foreign_key: true
      t.references :parent_message, foreign_key: { to_table: :messages }
      t.text :content, null: false
      t.string :user_ip, null: false
      t.float :ai_sentiment_score
      t.timestamps
    end
  end
end
