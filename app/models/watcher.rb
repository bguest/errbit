class Watcher < ActiveRecord::Base
  include Authority::Abilities


  belongs_to :app, :inverse_of => :watchers
  belongs_to :user

  validate :ensure_user_or_email
  validates :email, format: { with: Errbit::Config.email_regexp }, allow_blank: true, if: :email_changed?

  before_validation :clear_unused_watcher_type

  attr_accessor :watcher_type

  def watcher_type
    @watcher_type ||= email.present? ? 'email' : 'user'
  end

  def label
    user ? user.name : email
  end

  def address
    user.try(:email) || email
  end

  protected

    def ensure_user_or_email
      errors.add(:base, "You must specify either a user or an email address") unless user.present? || email.present?
    end

    def clear_unused_watcher_type
      case watcher_type
      when 'user'
        self.email = nil
      when 'email'
        self.user = self.user_id = nil
      end
    end

end

