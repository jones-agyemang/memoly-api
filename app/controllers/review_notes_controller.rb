# frozen_string_literal: true

class ReviewNotesController < ApplicationController
  def due_notes
    @results = DueNotes.call(user_id: user_id)

    render :index
  end

  private

  def user_id
    params.expect(:user_id)
  end
end
