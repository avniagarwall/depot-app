class ApplicationController < ActionController::Base
  before_action :set_i18n_locale_from_params
  before_action :increment_hit_counter
  before_action :check_session_timeout
  around_action :track_response_time
  before_action :set_locale

  include Authentication
  allow_browser versions: :modern
  include ActiveStorage::SetCurrent

  def set_i18n_locale_from_params
    if params[:locale]
      if I18n.available_locales.map(&:to_s).include?(params[:locale])
        I18n.locale = params[:locale]
      else
        flash.now[:notice] =
          "#{params[:locale]} translation not available"
        logger.error flash.now[:notice]
      end
    end
  end

  private

  def increment_hit_counter
    Rails.cache.increment("hit_counter", 1, expires_in: nil)
  end

  helper_method :hit_count

  def hit_count
    Rails.cache.read("hit_counter") || 0
  end

  def track_response_time
    start = Process.clock_gettime(Process::CLOCK_MONOTONIC)
    yield
    elapsed_ms = ((Process.clock_gettime(Process::CLOCK_MONOTONIC) - start) * 1000).round(2)
    response.set_header("x-responded-in", "#{elapsed_ms}ms")
  end

  INACTIVITY_TIMEOUT = 5.minutes

  def check_session_timeout
    return unless Current.user

    last_active = session[:last_active_at]

    if last_active && Time.current - Time.at(last_active) > INACTIVITY_TIMEOUT
      session.delete(:last_active_at)
      Current.session&.destroy
      redirect_to root_path, alert: I18n.t('flash.logged_out')
      return
    end

    session[:last_active_at] = Time.current.to_i
  end

  def set_locale
    I18n.locale = Current.user ? Current.user.locale : I18n.default_locale
  end

end