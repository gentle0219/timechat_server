# APNS.host = 'gateway.push.apple.com' 
APNS.host = 'gateway.sandbox.push.apple.com' 
# gateway.sandbox.push.apple.com is default

APNS.port = 2195 
# this is also the default. Shouldn't ever have to set this, but just in case Apple goes crazy, you can.

APNS.pem  = "#{Rails.root}/config/apns_dev.pem"
# this is the file you just created

APNS.pass = 'timechat'
# Just in case your pem need a password


# GCM.host = 'https://android.googleapis.com/gcm/send'
# # https://android.googleapis.com/gcm/send is default

# GCM.format = :json
# # :json is default and only available at the moment

# GCM.key = "AIzaSyCDBdnw00C2eCRMr6y7PS73g6ORnrcMDkw"
# # this is the apiKey obtained from here https://code.google.com/apis/console/