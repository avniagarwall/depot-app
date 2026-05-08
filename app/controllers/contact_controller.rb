class ContactsController < ApplicationController
  def new
    @contact_form = ContactForm.new
  end

  def create
    @contact_form = ContactForm.new(contact_params)

    if @contact_form.deliver
      redirect_to store_index_path, notice: "✅ Message sent successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

    def contact_params
      params.require(:contact_form).permit(:name, :email, :subject, :message)
    end
end