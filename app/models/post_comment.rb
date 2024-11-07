# frozen_string_literal: true
class PostComment < ApplicationRecord
  belongs_to :post

  validates :post, presence: true
  validates :comment, presence: true
  validates :username, presence: true
  validates :ip_address, presence: true
  validates :status, presence: true
  validates :locale, presence: true

  before_validation :set_defaults

  enum :status, [:status_new, :status_whitelisted, :status_unpublished]

  def self.ransackable_associations(auth_object = nil)
    ["post"]
  end

  def self.ransackable_attributes(auth_object = nil)
    ["comment", "created_at", "id", "ip_address", "locale", "post_id", "status", "updated_at", "username"]
  end

  def self.pretty_statuses
    self.statuses.transform_keys { |k| k.sub("status_", "") }
  end

  def self.recent_first
    order("#{table_name}.id DESC")
  end

  def self.whitelisted
    status_whitelisted
  end

  # @param String|Integer string_id
  # @return String
  def self.encode_id(string_id)
    string_id = string_id.to_s
    raise "Invalid string_id" if string_id.blank?
    chars = string_id.chars
    chars_sz = chars.size
    chars_magic = "17"
    chars.unshift(chars_sz.to_s)
    chars = chars_magic.chars + chars
    chars_max = 20
    until chars.size == chars_max
      chars << Random.rand(10).to_s
    end
    Base64.encode64(chars.join)[0..-3] # remove "=\n"
  end

  # @param String string_id
  # @return String, string repr. of integer
  def self.decode_id(string_id_enc)
    raise "Invalid string_id_enc" if string_id_enc.blank?
    string_id_enc += "=\n"
    decoded = Base64.decode64(string_id_enc)
    sz = decoded[2]
    decoded[3, sz.to_i]
  end

  # @param ip: String
  # @param time_cutoff: ActiveSupport::TimeWithZone
  def self.recent_by_ip(ip:, time_cutoff:)
    raise ArgumentError unless time_cutoff.is_a?(ActiveSupport::TimeWithZone)
    where(
      "#{table_name}.ip_address = :ip AND #{table_name}.created_at >= :time",
      ip: ip,
      time: time_cutoff.utc
    )
  end

  def whitelisted?
    self.status == "status_whitelisted"
  end

  def encoded_id
    raise "No Id" if self.id.blank?
    self.class.encode_id(self.id.to_s)
  end

  def pretty_status
    self.status.to_s.sub("status_", "")
  end

  protected

  def set_defaults
    self.locale ||= I18n.locale
    self.status ||= "status_new"
  end
end
