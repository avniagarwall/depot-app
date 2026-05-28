class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]
  rate_limit to: 10, within: 3.minutes, only: :create,
             with: -> { redirect_to new_session_path, alert: I18n.t("flash.session.rate_limited") }

  def new
  end

  def create
    if user = User.authenticate_by(params.permit(:email_address, :password))
      start_new_session_for user
      redirect_to user.admin? ? admin_reports_path : after_authentication_url,
                  notice: I18n.t("flash.session.created")
    else
      redirect_to new_session_path, alert: I18n.t("flash.session.invalid")
    end
  end

  def destroy
    terminate_session
    redirect_to new_session_path, status: :see_other,
                notice: I18n.t("flash.session.destroyed")
  end
end
