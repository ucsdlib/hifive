# frozen_string_literal: true

require 'net/ldap'
require 'ldap'

# User - authenticated Library user
class User < ApplicationRecord
  has_many :recognitions, dependent: :destroy

  def self.find_or_create_for_developer(_access_token)
    User.find_by(uid: 1, provider: 'developer') ||
      User.create(uid: 1, provider: 'developer', email: 'developer@ucsd.edu', full_name: 'developer')
  end

  # Finds or creates a shibboleth account
  # @param access_token [OmniAuth::AuthHash]
  def self.find_or_create_for_shibboleth(access_token)
    begin
      uid = access_token.uid
      email = access_token.info.email || "#{uid}@ucsd.edu"
      provider = access_token.provider
      name = access_token.info.name
    rescue StandardError => e
      logger.tagged('shibboleth') { logger.error e } && return
    end
    User.find_by(uid: uid, provider: provider) ||
      User.create(uid: uid, provider: provider, email: email, full_name: name)
  end

  def self.administrator?(uid)
    Ldap::Queries.hifive_group(uid) == uid
  end

  def developer?
    provider.eql?('developer')
  end

  # Determine whether the authenticated Shib user is Library staff
  # @param uid [String] example: 'drseuss'
  # @return [Boolean]
  def self.library_staff?(uid)
    Ldap::Queries.library_staff(uid) == uid
  end
end
