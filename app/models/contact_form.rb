class ContactForm
  # ACTIVE MODEL API
  # Includes: AttributeAssignment, Conversion, Naming, Translation, Validations
  include ActiveModel::API

  # ATTRIBUTES
  attr_accessor :name, :email, :subject, :message

  # VALIDATIONS
  validates :name,    presence: true, length: { minimum: 2, maximum: 50 }
  validates :email,   presence: true,
                      format: { with: URI::MailTo::EMAIL_REGEXP,
                                message: "must be a valid email address" }
  validates :subject, presence: true,
                      inclusion: { in: %w(billing technical general),
                                   message: "%{value} is not a valid subject" }
  validates :message, presence: true, length: { minimum: 10, maximum: 1000 }

  def deliver
    if valid?
      Rails.logger.info "📧 Contact form submitted by #{name} (#{email})"
      true
    else
      false
    end
  end
end