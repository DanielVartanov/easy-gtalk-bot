#!/usr/bin/ruby

require 'easy-gtalk'

account = Yaml.load('account.yml')

bot = GTalk::Bot.new(account)
bot.get_online

bot.on_invitation do |inviter|
  puts "I have been invited by #{inviter}. Yay!"

  bot.accept_invitation(inviter)
  bot.message(inviter, "Hello there! Thanks for invitation!")
end

bot.on_message do |from, text|
  puts "I got message from #{from}: '#{text}'"

  bot.message from, "You've told me something!"
end

Thread.stop

#get_online :invisible => true
#bot.set_status :away
#bot.set_status :available

#GTalk::Account('aldor.kg@gmail.com').available?
#GTalk::Account('aldor.kg@gmail.com').online?
#
#GTalk::Account('aldor.kg@gmail.com').in_contact_list?

#bot.contact_list # => [GTalk::Account.new, GTalk::Account.new]