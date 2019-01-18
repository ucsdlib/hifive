# frozen_string_literal: true

# Sends a recognition email
class RecognitionMailer < ApplicationMailer
  def email(recognition)
    @recognition = recognition
    opt_out_key(recognition.id)
    mail(to: mail_to_group,
         from: Rails.application.credentials.email[:sender],
         bcc: Rails.application.credentials.email[:bcc],
         subject: 'You have been recognized!')
  end

  def mail_to_group
    [@recognition.employee.email,
     manager_email(@recognition.employee.manager),
     @recognition.user.email].join(',')
  end

  def opt_out_key(id)
    optout_obj = OptOutLink.where(recognition_id: id).first
    @key = optout_obj ? optout_obj.key : Recognition.new.generate_key(id)
  end

  def manager_email(manager_uid)
    manager = Employee.find_by(uid: manager_uid)
    return manager.email if manager
  end
end
