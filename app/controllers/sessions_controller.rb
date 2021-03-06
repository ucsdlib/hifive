# frozen_string_literal: true

# SessionsController
class SessionsController < ApplicationController
  def new
    if ENV['AUTH_METHOD'] == 'google'
      redirect_to google_oauth2_path
    else
      redirect_to developer_path
    end
  end

  def developer
    find_or_create_user('developer')
  end

  def google_oauth2
    find_or_create_user('google_oauth2')
  end

  def failure
    render file: Rails.root.join('public', '403'), formats: [:html], status: 403, layout: false
  end

  def find_or_create_user(auth_type)
    find_or_create_method = "find_or_create_for_#{auth_type.downcase}".to_sym
    omniauth_results = request.env['omniauth.auth']
    user = User.send(find_or_create_method, omniauth_results)

    if valid_user?(auth_type, omniauth_results)
      create_user_session(user) if user
      flash[:notice] = "You have successfully authenticated from #{auth_type} account!"
      redirect_back_or root_url
    else
      render file: Rails.root.join('public', '403'), formats: [:html], status: 403, layout: false
    end
  end

  def destroy
    destroy_user_session

    # rubocop:disable Layout/LineLength
    redirect_to logout_url,
                notice: 'You have been logged out of High Five! To log out of all Single Sign-On applications, close your browser.'
    # rubocop:enable Layout/LineLength
  end

  private

  def valid_user?(auth_type, omniauth_results)
    return true if auth_type.eql? 'developer'

    uid = User.employee_uid(omniauth_results.info.email, omniauth_results.uid)
    auth_type == 'google_oauth2' && User.library_staff?(uid)
  end

  def create_user_session(user)
    session[:user_name] = user.full_name
    session[:user_id] = user.uid
  end

  def destroy_user_session
    session[:user_name] = nil
    session[:user_id] = nil
  end

  # Redirects to stored location (or to the default).
  def redirect_back_or(default)
    redirect_to(session[:forwarding_url] || default)
    session.delete(:forwarding_url)
  end
end
