class Leave < ActiveRecord::Base

  belongs_to :user

  CASUAL = 1
  MEDICAL = 2
  UNANNOUNCED = 3

  LEAVE_TYPES = [
      ['Casual Leave', CASUAL],
      ['Medical Leave', MEDICAL]
  ]

  ACCEPTED = 1
  REJECTED = 2
  PENDING = 3

  HOURS_FOR_ONE_DAY = 8
  HOURS_FOR_HALF_DAY = HOURS_FOR_ONE_DAY / 2

  LEAVE_STATUSES = [
      ['Approved', ACCEPTED],
      ['Rejected', REJECTED],
      ['Pending', PENDING]
  ]

  def update_leave_tracker
    consumed_casual_leave = self.user.leave_tracker.consumed_vacation.present? ? self.user.leave_tracker.consumed_vacation : 0
    consumed_medical_leave = self.user.leave_tracker.consumed_medical.present? ? self.user.leave_tracker.consumed_medical : 0

    if self.end_date.present?
      total_hours = (1 + (self.end_date - self.start_date).to_i) * HOURS_FOR_ONE_DAY
    else
      total_hours = HOURS_FOR_ONE_DAY
    end

    if self.half_day
      total_hours_to_be_sonsumed = total_hours - HOURS_FOR_HALF_DAY
    else
      total_hours_to_be_sonsumed = total_hours
    end

    if self.leave_type == CASUAL || self.leave_type == UNANNOUNCED
      consumed_casual_leave_balance = consumed_casual_leave.to_i + total_hours_to_be_sonsumed
      self.user.leave_tracker.update_attributes(:consumed_vacation => consumed_casual_leave_balance)
    else
      consumed_medical_leave_balance = consumed_medical_leave + total_hours_to_be_sonsumed
      self.user.leave_tracker.update_attributes(:consumed_medical => consumed_medical_leave_balance)
    end
  end

  def is_pending?
    self.status == PENDING
  end

  def is_accepted?
    self.status == ACCEPTED
  end

  def is_rejected?
    self.status == REJECTED
  end
end
