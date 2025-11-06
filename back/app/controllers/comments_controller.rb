class CommentsController < ApplicationController
  Mongoid.raise_not_found_error = false
  before_action :authorize_request, only: %i[show index]
  before_action :set_comment, only: %i[show update destroy]

  # GET /comments/{post_id}
  def index
    @comments = Comment.all.where({post_id: params[:id]})
    render json: @comments
  end

  # GET /comments/1
  def show
    render json: @comment
  end

  # POST /comments
  def create
    user = authorize_request

    begin
      raise(*create_object_error) if @post.nil?

      comment = post.comments.create!({ user_id: user.id, content: comment_params[:content] })
      render json: comment, status: :created
    rescue Mongoid::Errors => e
      render json: { error: e }, status: :bad_request
    rescue UserService::InvalidUserException => e
      render json: { error: e }, status: :bad_request
    end
  end

  # POST /comments/1
  def like
    user = authorize_request
    com_params = params.require(:comments).permit(:post_id, :author_id, :id)

    begin
      raise(*create_object_error) if @post.nil?

      comment = CommentService.get_comment(com_params[:id], @post)
      render LikeService.like(user.id, comment)
    rescue StandardError => e
      render json: { error: e }, status: :bad_request
    end
  end

  # DELETE /comments/1
  def destroy
    user = authorize_request

    unless user.id == @comment.user_id
      return render json: { error: 'Specified user is not the owner of the comment' }, status: :bad_request
    end

    @comment.destroy
  end

  private
  def post
    @post = PostService.get_post(params[:author_id], params[:post_id])
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_comment
    @comment = Comment.find(params[:id])
  end

  # Only allow a list of trusted parameters through.
  def comment_params
    params.require(:comment).permit(:user_id, :content, :post_id).tap { |c| c.require(%i[user_id content post_id]) }
  end
end
