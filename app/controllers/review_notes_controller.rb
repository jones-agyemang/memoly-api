# frozen_string_literal: true

class ReviewNotesController < ApplicationController
  def due_notes
    @results = DueNotes.call(user_id:, date: due_date)

    render :index
  end

  private

  def user_id
    params.expect(:user_id)
  end

  def due_date
    return Time.zone.today if params[:date].blank?

    Time.zone.parse(params[:date]).to_date
  rescue ArgumentError, TypeError
    Time.zone.today
  end
end
