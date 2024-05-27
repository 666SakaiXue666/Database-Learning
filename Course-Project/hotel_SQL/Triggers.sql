-- Triggers

--  To avoid people booking a time slot that conflicts or overlaps with those already booked by other people. 
delimiter $$
create trigger New_Booking
before insert on booking
for each row
begin
if exists(
select *
from booking
where new.room_id = room_id
and not(
new.check_in_time > check_out_time 
or new.check_out_time < check_in_time)
)
then signal sqlstate '45000' set message_text = 'Time Conflict';
end if;
end$$
delimiter ;

-- Insert a record with a time slot that conflicts with others. 
START TRANSACTION;
insert into Booking (book_id, room_id, check_in_time, check_out_time, paid)
values ('B011', '1001', '2024-04-30 15:00:00', '2024-04-30 17:00:00', 0);
ROLLBACK;