require 'digest/sha1'

class Conversation
  include Mongoid::Document
  include Mongoid::Timestamps

  field :lookup_hash, type: String  
  field :last_message_time, type: DateTime, default: -> { Time.now }
  # Array of user ids of users that have read all messages in this conversation
  field :last_message_seen_by, type: Array, default: []

  belongs_to :user
  has_many :messages, :dependent => :destroy, order: ("created_at DESC")
  has_and_belongs_to_many :participants, :class_name => 'User'

  validates_presence_of :lookup_hash

  index({ lookup_hash: 1 }, { unique: true, name: "lookup_hash_index" })
  # Used to show a user a list of conversations ordered by last_message_time
  index({ _id: 1, last_message_time: -1 }, { unique: true, name: "id_last_message_time_index" })


  def have_unread_message(user)
    unread_messages = self.messages.where(read: false, receiver_id:user.id).order_by('created_at DESC')
  end

  def self.add_message(recipient, sender, message)
    # Find or create a conversation:
    lookup_hash = Conversation.get_lookup_hash([recipient.id, sender.id])
    conversation = Conversation.find_or_create_by(lookup_hash)    
    conversation.participants.concat [recipient, sender]
    # conversation.messages << message    
    conversation.last_message_time = Time.now
    conversation.last_message_seen_by.delete(recipient)
    conversation.user = sender
    conversation.lookup_hash = lookup_hash
    conversation.save
    message.update_attribute(:conversation_id, conversation.id)
  end

  def self.find_or_create_by(lookup_hash)
    cn = Conversation.where(lookup_hash:lookup_hash).first
    if cn.present?
      cn
    else
      cn = Conversation.new
    end
  end

  private
    def self.get_lookup_hash(participant_ids)
      lookup_key = participant_ids.sort.join(':')
      Digest::SHA1.hexdigest lookup_key
    end
end