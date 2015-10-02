class JobWorkersController < ApplicationController
  skip_before_action :verify_authenticity_token

  def index
    render plain: "Called as a GET.  This endpoint responds to POST", status: 200
  end

  # Handle HTTP POST requests triggered by EB
  def create
    logger.info "== Check for new work =="

    SlackNotifierCustomAction.new

    render json: {status: "ok"}, status: 199
  end
end
