class PostsController < ApplicationController
  before_action :authenticate_user!, :only => [:new, :create, :edit, :update, :destroy, :favorite, :unfavorite]
  before_action :find_group_post_and_check_permission, only: [:edit, :update, :destroy]
  before_action :validate_search_key, only: [:search]

  def index
    @posts = Post.all.recent.paginate(:page => params[:page], :per_page => 30)
  end

  def show
    @group = Group.find(params[:group_id])
    @post = Post.find(params[:id])
    set_page_title @post.title
    set_page_description "#{@post.content}"    
    @post_comments = @post.post_comments.paginate(:page => params[:page], :per_page => 10)
    @commends = Post.where.not(:id => @post.id ).random5
  end

  def new
    @group = Group.find(params[:group_id])
    @post = Post.new
  end

  def create
    @group = Group.find(params[:group_id])
    @post = Post.new(post_params)
    @post.group = @group
    @post.user = current_user

    if @post.save
      redirect_to group_path(@group)
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @post.update(post_params)
      redirect_to group_post_path(@group,@post), notice:"更新成功！"
    else
      render :edit
    end
  end

  def destroy
    @post.destroy
    redirect_to group_path(@group), alert: "删除成功！"
  end

  # --收藏功能---
  def favorite
    @post = Post.find(params[:id])
    @group = Group.find(params[:group_id])

    if !current_user.is_favor_of_post?(@post)
      current_user.favorite_post!(@post)
    end
      redirect_to group_post_path(@group,@post)
  end

  def unfavorite
    @post = Post.find(params[:id])
    @group = Group.find(params[:group_id])

    if current_user.is_favor_of_post?(@post)
      current_user.unfavorite_post!(@post)
    end
      redirect_to group_post_path(@group,@post)
  end

  def search
    if @query_string.present?
      search_result = Post.ransack(@search_criteria).result(:distinct => true)
      @posts = search_result.paginate(:page => params[:page], :per_page => 10 )
    end
  end

  protected

  def validate_search_key
    @query_string = params[:q].gsub(/\\|\'|\/|\?/, "") if params[:q].present?
    @search_criteria = search_criteria(@query_string)
  end


  def search_criteria(query_string)
    { :title_cont => query_string }
  end

  private
  def find_group_post_and_check_permission
    @group = Group.find(params[:group_id])
    @post = Post.find(params[:id])

    if current_user != @post.user
      redirect_to root_path, alert: "抱歉，您没有相应的权限！"
    end
  end

  def post_params
    params.require(:post).permit(:title, :content)
  end


end
