class Admin::TagsController < Admin::BaseController
  def index
    @tags = Tag.ordered.includes(:products)
    @selected_tag = Tag.find_by(name: params[:tag])
    @products = @selected_tag ? @selected_tag.products.includes(:tags, :category, images_attachments: :blob) : []

    respond_to do |format|
      format.html
      format.json { render json: @tags.map { |t| { id: t.id, name: t.name, count: t.products.size } } }
    end
  end

  def create
    @tag = Tag.find_or_initialize_by(name: params[:name].to_s.strip.titleize)

    respond_to do |format|
      if @tag.save
        format.html { redirect_to admin_tags_path, notice: "Tag '#{@tag.name}' created." }
        format.json { render json: { id: @tag.id, name: @tag.name }, status: :created }
      else
        format.html { redirect_to admin_tags_path, alert: @tag.errors.full_messages.to_sentence }
        format.json { render json: { errors: @tag.errors.full_messages }, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy
    redirect_to admin_tags_path, notice: "Tag '#{@tag.name}' deleted."
  end
end
