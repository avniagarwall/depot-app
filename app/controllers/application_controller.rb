class ApplicationController < ActionController::Base
  include Authentication
  include ActiveStorage::SetCurrent

  # Only allow modern browsers supporting webp images, web push, badges,
  # import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_i18n_locale_from_params
  before_action :check_inactivity
  before_action :increment_hit_counter
  around_action :track_response_time

  helper_method :hit_count

  private

    def set_i18n_locale_from_params
      if params[:locale]
        if I18n.available_locales.map(&:to_s).include?(params[:locale])
          I18n.locale = params[:locale]
        else
          flash.now[:notice] = I18n.t("flash.locale.unavailable", locale: params[:locale])
          logger.error flash.now[:notice]
        end
      end
    end

    def check_inactivity
      if session[:last_active].present? &&
         Time.current - session[:last_active].to_time > 5.minutes
        reset_session
        redirect_to root_path, alert: I18n.t("flash.session.expired")
        return
      end
      session[:last_active] = Time.current
    end

    def increment_hit_counter
      Rails.cache.increment("hit_counter", 1)
    end

    def hit_count
      Rails.cache.read("hit_counter") || 0
    end

    def track_response_time
      start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
      yield
      elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
      response.set_header("x-responded-in", "#{elapsed_ms}ms")
    end
end