#!/usr/bin/env ruby

$LOAD_PATH.push File.expand_path('../../lib', __FILE__)

require 'require_all'
require 'logger'
require 'active_record'
require 'securerandom'

ENV['RACK_ENV'] = ENV['RACK_ENV'] || 'development'

require 'cyclid/config'

module Cyclid
  class << self
    attr_accessor :logger, :config

    begin
      Cyclid.logger = Logger.new(STDERR)

      config_path = ENV['CYCLID_CONFIG'] || File.join(%w(/ etc cyclid config))
      Cyclid.config = API::Config.new(config_path)
    rescue StandardError => ex
      abort "Failed to initialize: #{ex}"
    end
  end
end

require 'db'
require 'cyclid/models'

include Cyclid::API

ADMINS_ORG = 'admins'.freeze
RSA_KEY_LENGTH = 2048

def generate_password
  (('a'..'z').to_a.concat \
   ('A'..'Z').to_a.concat \
   ('0'..'9').to_a.concat \
   %w($ % ^ & * _)).shuffle[0,8].join
end

def create_admin_user
  secret = SecureRandom.hex(32)
  password = generate_password
  user = User.new
  user.username = 'admin'
  user.email = 'admin@example.com'
  user.secret = secret
  user.new_password = password
  user.save!

  [secret, password]
end

def create_admin_organization
  key = OpenSSL::PKey::RSA.new(RSA_KEY_LENGTH)

  org = Organization.new
  org.name = ADMINS_ORG
  org.owner_email = 'admins@example.com'
  org.rsa_private_key = key.to_der
  org.rsa_public_key = key.public_key.to_der
  org.salt = SecureRandom.hex(32)
  org.users << User.find_by(username: 'admin')
end

def update_user_perms
  # 'admin' user is a Super Admin
  user = User.find_by(username: 'admin')
  organization = user.organizations.find_by(name: ADMINS_ORG)
  permissions = user.userpermissions.find_by(organization: organization)
  Cyclid.logger.debug permissions

  permissions.admin = true
  permissions.write = true
  permissions.read = true
  permissions.save!
end

secret, password = create_admin_user
create_admin_organization

update_user_perms

STDERR.puts '*' * 80
STDERR.puts "Admin secret: #{secret}"
STDERR.puts "Admin password: #{password}"
