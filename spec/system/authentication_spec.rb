require 'rails_helper'

RSpec.describe 'authenticating', type: :system do
  context 'as a user with no google_oauth2 credentials' do
    before do
      mock_valid_library_employee
      omniauth_setup_google_oauth2
      OmniAuth.config.mock_auth[:google_oauth2] = :invalid_credentials
      OmniAuth.config.on_failure = Proc.new { |env|
        OmniAuth::FailureEndpoint.new(env).redirect_to_failure
      }
    end

    it 'should not allow access to the application' do
      sign_in
      expect(page).to have_content('Forbidden')
    end
  end

  context 'as a developer' do
    before do
      mock_valid_library_employee
      omniauth_setup_developer
      mock_library_administrator
    end

    after(:all) do
      ENV['AUTH_METHOD'] = 'google'
    end

    it 'enforces authentication' do
      visit recognitions_path
      expect(page).to have_content('Sign out')
    end

    it 'redirects to logout url on sign out' do
      sign_in
      sign_out
      expect(page).to have_current_path(logout_path)
      expect(page).to have_content('You have been logged out of High Five!')
      expect(page).to have_content('Sign in')
    end
  end

  context 'as a regular user with google_oauth2' do
    before do
      omniauth_setup_google_oauth2
    end

    it 'allows access for library staff' do
      mock_valid_library_employee
      mock_non_library_administrator
      sign_in
      expect(page).to have_content('Sign out')
    end

    it 'does not allow access for non-library staff' do
      mock_invalid_library_employee
      sign_in
      expect(page).to have_content('Forbidden')
    end

    it 'redirects to logout url on sign out' do
      mock_valid_library_employee
      mock_non_library_administrator
      sign_in
      sign_out
      expect(page).to have_current_path(logout_path)
      expect(page).to have_content('You have been logged out of High Five!')
      expect(page).to have_content('Sign in')
    end
  end
end
