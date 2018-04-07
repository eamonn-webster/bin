#!/usr/bin/env ruby
#
# File: filter_log.rb
# Author: eweb
# Copyright qstream, 2013-2018
# Contents:
#
# Date:          Author:  Comments:
#  5th Nov 2013  eweb     #0008 Filter boring and known lines from log
# 24th Jun 2014  eweb     #0008 More noise to filter out
#  7th Apr 2018  eweb     #0007 rubocop
#

File.open(ARGV[1] || "filtered-#{ARGV[0]}", 'w') do |out|
  File.open(ARGV[0]) do |f|
    f.each do |line|
      if line =~ /measure=/
      elsif line =~ /sample#memory_total=/
      elsif line =~ /sample#load_avg_1m=/
      elsif line =~ / - -$/
      elsif line =~ / - - Started [A-Z]+ /
      elsif line =~ /Resque: \(Job/
      elsif line =~ /source=rack-timeout.+state=(completed|ready)/
      elsif line =~ /heroku router - - at=info method=/
      elsif line =~ /heroku nginx - - .+ ".+ HTTP\/1.1" (200|302|304|206)/
      elsif line =~ /heroku nginx - - .+ ".+ HTTP\/1.1" (401|404|406|408)/
        #puts line
      elsif line =~ /NewRelic.+ INFO :/
      elsif line =~ /NewRelic.+ WARN :/
      elsif line =~ %r{app/modules/query_string_filter.rb}
      elsif line =~ /Warning: Only [0-9]+ of the [0-9]+ users are assigned to a group/
      elsif line =~ /WARNING: No available_types so using default/
      elsif line =~ /WARNING: Leaderboard type .+ not available will use .+/
      elsif line =~ /Urbanairship \([0-9]+ms\): \[Post \/api\/push\/, {"device_tokens"/
      elsif line =~ /- -     "push_id": ".+"$/
      elsif line =~ / - - }\]$/
      elsif line =~ /Urbanairship \([0-9]+ms\): \[Put \/api\/device_tokens\/.+, {}\], \[200, OK\]/
      elsif line =~ /ActionController::RoutingError \(No route matches \[GET\]/
      elsif line =~ /ActionController::RoutingError \(No route matches \[POST\]/
        #puts line
      elsif line =~ /app scheduler\./
      elsif line =~ /\(.+\) Request phase initiated/
      elsif line =~ /\(.+\) Callback phase initiated/
      elsif line =~ / - - Disconnected from Redis/
      elsif line =~ / - - Connected to Redis/
      elsif line =~ /INFO -- : worker=[0-9]+ ready/
      elsif line =~ /INFO -- : master process ready/
      elsif line =~ /heroku api - - Starting process with command/
      elsif line =~ /heroku scheduler.[0-9]+ - - Starting process with command/
      elsif line =~ /heroku .+.[0-9]+ - - State changed from .+ to .+/
      elsif line =~ /heroku .+\.[0-9]+ - - Process exited with status 0/
      elsif line =~ /heroku .+\.[0-9]+ - - Process exited with status [0-9]+/
      elsif line =~ /warning: redefining `object_id' may cause serious problems/
      elsif line =~ / INFO -- : Refreshing Gem list/
      elsif line =~ /Unicorn worker intercepting TERM and doing nothin/
      elsif line =~ /Stopping all processes with SIGTERM/
      elsif line =~ / - - Cycling$/
      elsif line =~ /INFO -- : reaped/
      elsif line =~ /INFO -- : master complete/
      elsif line =~ /INFO -- : listening on addr=0.0.0.0:/
      elsif line =~ /Unicorn master intercepting TERM and sending myself QUIT instead/
      elsif line =~ /Error R12 \(Exit timeout\) -> At least one process failed to exit within 10 seconds of SIGTERM/
      elsif line =~ /Stopping remaining processes with SIGKILL/
      elsif line =~ /Starting process with command/
      elsif line =~ /Error R10 \(Boot timeout\) -> Web process failed to bind to \$PORT within 60 seconds of launch/
      elsif line =~ /Stopping process with SIGKILL/
      elsif line =~ /HTTPI [A-Z]+ request to .+ \(httpclient\)/
      elsif line =~ /- - SOAP request:/
      elsif line =~ /- - SOAPAction:/
      elsif line =~ /- - SOAP login response:/
      elsif line =~ /- - SOAP response \(status 200\)/
      elsif line =~ /- - <\?xml version="1.0" encoding="UTF-8"\?>/i
      elsif line =~ /\*\* \[Airbrake\] Success: Net::HTTPOK/
      elsif line =~ /sh: indexer: not found/
      elsif line =~ /- - unsubscribing user [0-9]+ [0-9]+/
      elsif line =~ /heroku router - - at=error code=H17 desc="Poorly formatted HTTP response" method=GET/
      elsif line =~ /\[AWS S3 (200|204) [.0-9]+ 0 retries\] [a-z]+_object/
      elsif line =~ /- - {"message"=>"Email does not exist"}/
      elsif line =~ %r{/app/vendor/bundle/ruby/1.9.1/gems}
      elsif line =~ %r{/app/vendor/ruby-1.9.3/lib/ruby/1.9.1}
      elsif line =~ %r{/app/vendor/bundle/ruby/1.9.1/bin/rake}
      elsif line =~ %r{app/modules/localized_application.rb:35:in `set_locale'}
      elsif line =~ %r{lib/set_cookie_domain.rb:14:in `call'}
      elsif line =~ /Scale to web=[0-9]+, worker=[0-9]+/
      elsif line =~ /Completed 200 OK/
      elsif line =~ /Processing by/
      elsif line =~ /Parameters: /
      elsif line =~ /Filter chain halted/
      elsif line =~ /Completed 302/
      elsif line =~ /Redirected to /
      elsif line =~ /Process running mem/
      elsif line =~ /Memory quota exceeded/
      elsif line =~ /Setting locale to:/
      elsif line =~ /Sent mail to /
      elsif line =~ /Completed 406 Not Acceptable/
      elsif line =~ /Rendered /
      elsif line =~ /Stopping delivery/
      elsif line =~ /XXXX/
      else
        puts line
        out.puts line
      end
    end
  end
end
