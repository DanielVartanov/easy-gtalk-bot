require 'openssl'

require "xmpp4r"
require 'xmpp4r/roster'

module JabberExtensions
  module JIDExtensions
    def to_email
      "#{self.node}@#{self.domain}"
    end
  end

  Jabber::JID.__send__ :include, JIDExtensions
end

module GTalk
  class Bot
    include Jabber
    attr_reader :email, :password
    attr_reader :jabber_client, :jid

    def initialize(account_data)
      @email = account_data[:email]
      @password = account_data[:password]

      @jid = JID::new(self.email)
      @jabber_client = Client.new(self.jid)
    end

    def get_online
      self.jabber_client.connect
      self.jabber_client.auth(self.password)
      self.jabber_client.send(Presence.new.set_type(:available))
    end

    def invite(invitee)
      subscription_request = Presence.new.set_type(:subscribe).set_to(JID::new(invitee))
      self.jabber_client.send(subscription_request)
    end

    def accept_invitation(inviter)
      inviter = JID::new(inviter)
      self.roster.accept_subscription(inviter)
      invite(JID::new(inviter))
    end

    def message(to, text)
      message = Message::new(JID::new(to), text)
      message.type = :chat
      self.jabber_client.send(message)
    end

    def on_invitation(&block)
      self.roster.add_subscription_request_callback do |_, presence|
        block.call(presence.from.to_email)
      end
    end

    def on_message(&block)
      self.jabber_client.add_message_callback do |message|
        block.call(message.from.to_email, message.body)
      end
    end

  protected

    def roster
      @roster ||= Roster::Helper.new(self.jabber_client)
    end
  end
end