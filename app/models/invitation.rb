class Invitation < ActiveRecord::Base
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  belongs_to :world

  validates :receiver_id, uniqueness: { 
    scope: [:world_id, :status],
    conditions: -> { where(status: ['pending', 'accepted']) },
    message: 'has already been invited to this world'
  }
end
