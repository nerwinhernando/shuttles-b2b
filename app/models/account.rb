class Account < ApplicationRecord
  has_many :users, dependent: :destroy

  validates :name, presence: true
  validates :subdomain, presence: true, uniqueness: true
  validates :subdomain, format: {
    with: /\A[a-z0-9]+[a-z0-9\-]*[a-z0-9]+\z/,
    message: 'only allows lowercase letters, numbers, and hyphens'
  }
  validates :subdomain, exclusion: {
    in: %w[www admin api app help support blog],
    message: '%{value} is reserved'
  }

  PLANS = %w[basic premium enterprise].freeze
  validates :plan, inclusion: { in: PLANS }

  before_validation :downcase_subdomain

  scope :active, -> { where(active: true) }

  def owner
    users.where(role: 'admin').first
  end

  private

  def downcase_subdomain
    self.subdomain = subdomain.downcase if subdomain.present?
  end
end
