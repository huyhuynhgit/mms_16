class User < ApplicationRecord
  attr_accessor :remember_token
  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
  validates :email, length: {maximum: Settings.user.email_max_length},
    format: {with: VALID_EMAIL_REGEX}, presence: true, uniqueness: {case_sensitive: false}
  validates :password, presence: true, length: {minimum: Settings.user.password_min_length}, allow_nil: true
  validates :name, presence: true, length: {maximum: Settings.user.name_max_length}
  before_save :downcase_email
  has_secure_password

  has_many :project_users, dependent: :destroy
  has_many :projects, through: :project_users
  has_many :skill_users, dependent: :destroy
  has_many :skills, through: :skill_users
  belongs_to :team
  belongs_to :position

  def self.digest string
    cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST : BCrypt::Engine.cost
    BCrypt::Password.create string, cost: cost
  end

  def self.new_token
    SecureRandom.urlsafe_base64
  end

  def remember
    self.remember_token = User.new_token
    update_attribute :remember_digest, User.digest(remember_token)
  end

  def authenticated? remember_token
    return false unless remember_digest
    BCrypt::Password.new(remember_digest).is_password? remember_token
  end

  def forget
    update_attribute :remember_digest, nil
  end

  def downcase_email
    self.email = email.downcase
  end
end
