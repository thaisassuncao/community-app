# frozen_string_literal: true

class CommunitiesController < ApplicationController
  def index
    @communities = Community.includes(:messages).all
  end

  def show
    @community = Community.find(params[:id])
    @messages = @community.messages
                          .where(parent_message_id: nil)
                          .includes(:user, :reactions)
                          .order(created_at: :desc)
                          .limit(50)
    @message = Message.new
  end
end
