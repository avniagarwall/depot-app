class Admin::TagsController < Admin::BaseController
  before_action :set_tag, only: [:destroy]

  def index
    @tags = Tag.ordered.includes(:products)
    @selected_tag = Tag.find_by(name: params[:tag])
    @products = @selected_tag ? @selected_tag.products.includes(:tags, :category, images_attachments: :blob) : []

    respond_to do |format|
      format.html
    end
  end

  def create
    @tag = Tag.find_or_initialize_by(name: params[:name].to_s.strip.titleize)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to admin_tags_path, notice: "Tag '#{@tag.name}' created." }
      else
        format.html { redirect_to admin_tags_path, alert: @tag.errors.full_messages.to_sentence }
      end
    end
  end

  def destroy
    tag_name = @tag.name

    if @tag.destroy
      redirect_to admin_tags_path, notice: "Tag '#{tag_name}' deleted."
    else
      redirect_to admin_tags_path, alert: "Could not delete tag '#{tag_name}'. #{@tag.errors.full_messages.join(', ')}"
    end
  end

  private def set_tag
    @tag = Tag.find_by(id: params[:id])
    unless @tag
      redirect_to admin_tags_path, alert: "Tag not found."
    end
  end
end