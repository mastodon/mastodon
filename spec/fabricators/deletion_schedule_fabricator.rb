Fabricator(:deletion_schedule) do
  user
  delay 30.days.seconds
end
