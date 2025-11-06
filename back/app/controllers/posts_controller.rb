class PostsController < ApplicationController
  before_action :set_post, only: :show
  before_action :set_posts, only: :index
  before_action :authorize_request, only: %i[show index]

  # GET /posts/1
  def index
    render json: @post
  end

  # GET /post/1
  def show
    render json: @post
  end

  # POST /posts
  def create
    user = authorize_request
    return if params[:image].nil?
    return render json: { error: 'User is not a photographer' } unless user.photographer
    
    bucket = FireStorageService.instance.img_bucket
    file_uploaded = params[:image].tempfile
    filename = PostService.parse_filename(user.name, params[:image].content_type) # strategy pattern aplicando o parse no constrututor
    res = bucket.create_file(file_uploaded, filename)
    post_hash = PostService.post_params(params[:title], params[:price], res.name)
    
    begin
      user.posts.create!(post_hash)
      render json: p, status: :created
    rescue Mongoid::Errors => e
      bucket.file(filename).delete
      render error: e, status: :unprocessable_entity
    end
  end

  # POST /posts/1
  def like
    user = authorize_request
  end

  # DELETE /posts/1
  def destroy
    user = authorize_request

    begin 
      post = user.posts.find(params[:id])

      bucket = FireStorageService.instance.img_bucket
      bucket.file(post.image).delete
      user.posts.delete(post)
      render json: post, status: :ok
    rescue Mongoid::Errors => e
      render json: { error: e }, status: :unprocessable_entity
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_posts
      @post = PostService.user_posts(params[:id])
    end

    def set_post
      @post = User.find(params[:u_id]).posts.find(params[:p_id])
    end

    # Only allow a list of trusted parameters through.
    def post_params
      params.permit(:image, :price, :title).tap { |p| p.require(:image) }
    end
end
