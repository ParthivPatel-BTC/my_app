class AppointmentRequest < Sequel::Model
  many_to_one :customer
end