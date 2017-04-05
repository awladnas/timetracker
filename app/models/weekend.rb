class Weekend < ActiveRecord::Base
  has_many :users, dependent: :nullify
  has_many :exclusion_dates, as: :excluded, dependent: :destroy

  include OffDays

  validates_presence_of :name, message: 'must be provided.'
  validates_presence_of :off_days, message: 'cannot be empty.'

  def self.today? user
    today = Date.today.strftime('%A')
    counter = 0

    user.weekend.off_days.map(&:capitalize).each do |weekend|
      counter += 1 if weekend.to_s == today
    end

    counter > 0 ? true : false
  end
end
