class ApplicationMailer < ActionMailer::Base
  default from: "notification@memoly.io"
  layout "mailer"
end
