AUTHOR: Martin Javier
Before using this program make sure you have the following prerequisites:
1. Ruby Version. 2.0.0.p247 Installed. (Refer to getting_started_ruby.docx)
2. Unix Based OS Machine: Fedora 19, MacOSX
3. Make sure the files you'll want to transfer is in the same directory as your Ruby program

**IMPORTANT**
**IMPORTANT** Client.rb, Server.rb, SelectServer_R.rb, ServerEpoll.rb [Change the Port and IP address in the program] **IMPORTANT**
**IMPORTANT** To change the IP and PORT, Change on this line:
**IMPORTANT** server = TCPServer.new('127.0.0.1',7005)

Run the following in sequence, Server then Client.

1. [RUNNING IN TERMINAL - Server]
**IMPORTANT**
cd ~/libs
ruby Server.rb


2. [RUNNING IN TERMINAL - Client]
cd ~/libs
ruby Client.rb

**IMPORTANT** Install Missing Dependencies For Ruby Env **IMPORTANT**
yum -y install ruby-irb rubygems rubygem-bigdecimal rubygem-rake rubygem-i18n
yum -y install git
yum-builddep -y ruby
yum -y install ruby-devel libpcap-devel




