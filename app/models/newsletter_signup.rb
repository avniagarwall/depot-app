class NewsletterSignup
  # ACTIVE MODEL CALLBACKS
  # Gives plain Ruby objects Active Record style callbacks
  extend ActiveModel::Callbacks

  define_model_callbacks :subscribe, only: [:before, :after]
  define_model_callbacks :unsubscribe, only: [:before, :around, :after]

  attr_accessor :email, :subscribed

  before_subscribe :validate_email
  after_subscribe  :send_welcome_email

  before_unsubscribe  :log_unsubscribe
  around_unsubscribe  :wrap_unsubscribe
  after_unsubscribe   :send_goodbye_email

  def subscribe
    run_callbacks(:subscribe) do
      self.subscribed = true
      Rails.logger.info "✅ #{email} subscribed"
    end
  end

  def unsubscribe
    run_callbacks(:unsubscribe) do
      self.subscribed = false
      Rails.logger.info "❌ #{email} unsubscribed"
    end
  end

  private

    def validate_email
      unless email.include?("@")
        throw :abort
      end
    end

    def send_welcome_email
      Rails.logger.info "📧 Welcome email sent to #{email}"
    end

    def log_unsubscribe
      Rails.logger.info "📋 Logging unsubscribe for #{email}"
    end

    def wrap_unsubscribe
      Rails.logger.info "🔄 Starting unsubscribe process"
      yield
      Rails.logger.info "🔄 Unsubscribe process complete"
    end

    def send_goodbye_email
      Rails.logger.info "👋 Goodbye email sent to #{email}"
    end
end