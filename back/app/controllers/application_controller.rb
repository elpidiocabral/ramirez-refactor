class ApplicationController < ActionController::API
  before_action :set_header

  def authorize_request
    @current_user = UserAuthFacade.new(@header).decode_user
    return @current_user ? @current_user : UserNull.instance
    
  rescue JWT::DecodeError => e
    render json: { error: e.message }, status: :unauthorized
  rescue StandardError => e
    render json: { error: e.message }, status: :internal_server_error
  end

  private

  def set_header
    @header = request.headers['Authorization']
    @header = @header.split(' ').last if @header
  end
end
