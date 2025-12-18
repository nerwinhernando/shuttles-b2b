class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  belongs_to :account, optional: true

  validates :first_name, :last_name, presence: true
  validates :email, uniqueness: true

  ROLES = %w[customer coach super_admin admin staff venue_manager].freeze
  validates :role, inclusion: { in: ROLES }

  PLAYER_TYPES = %w[singles doubles both].freeze
  validates :player_type, inclusion: { in: PLAYER_TYPES }, allow_nil: true

  SKILL_LEVELS = %w[beginner intermediate advanced professional].freeze
  validates :skill_level, inclusion: { in: SKILL_LEVELS }, allow_nil: true

  scope :active, -> { where(active: true) }
  scope :admins, -> { where(role: 'admin') }
  scope :super_admins, -> { where(role: 'super_admin') }
  scope :staff, -> { where(role: 'staff') }
  scope :customers, -> { where(role: %w[customer coach]) }
  scope :venue_staff, -> { where(role: %w[admin staff venue_manager]) }

  def full_name
    "#{first_name} #{last_name}"
  end

  def customer?
    role == 'customer' || role == 'coach'
  end

  def coach?
    role == 'coach'
  end

  def super_admin?
    role == 'super_admin'
  end

  def admin?
    role == 'admin'
  end

  def staff?
    role == 'staff'
  end

  def venue_manager?
    role == 'venue_manager'
  end

  def venue_staff?
    admin? || staff? || venue_manager?
  end

  def can_manage_venue?(venue = nil)
    return true if super_admin?
    return false unless account_id.present?
    return false if venue && venue.account_id != account_id

    admin? || venue_manager?
  end
end
