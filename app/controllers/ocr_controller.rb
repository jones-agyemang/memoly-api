class OcrController < ApplicationController
  before_action :doorkeeper_authorize!

  def create
    extraction = ::Ocr::ExtractText.call(image_file)

    if extraction.success?
      render json: extraction.output
    else
      render json: extraction.output, status: :unprocessable_entity
    end
  end

  private

  def image_file
    params.expect(:image)
  end
end
