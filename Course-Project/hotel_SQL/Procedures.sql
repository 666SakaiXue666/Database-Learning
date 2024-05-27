-- Procedures

-- 1. Increase the salaries of staffs in Rooms structure at a certain rate. 
delimiter $$
create procedure raise_Rooms_salary (in rate numeric(2,2))
begin
    if rate > 0 then
        update Job
        set salary = salary * (1 + rate)
        where struc_name = 'Rooms';
    else
        signal sqlstate '45000' set message_text = 'raise: rate should be > 0';
    end if;
end$$
delimiter ;

-- call. increase the salary at the rate of 0.2
START TRANSACTION;
call raise_Rooms_salary (0.2);
ROLLBACK;



-- 2. The procedure is for customers to pay for their rooms. When a customer pays the room fee, 
--    the transaction amount should be recorded as the price of the room booked by the customer, 
--    and the Rooms structure is considered to have made the transactions with it. What’s more, the 
--    room booking order should be modified to paid.
delimiter $$
create procedure pay_for_room (in new_trans_id char(4),
                               in new_book_id char(4),
                               in new_execute_id char(4),
                               in new_trans_time datetime)
begin
    if exists (select * from booking 
               where book_id = new_book_id and paid = 0) then
        # Transaction add a new row
        insert into Transactions (trans_id, book_id, struc_name, execute_ID,  trans_time, amount)
        select new_trans_id, new_book_id, 'Rooms', new_execute_ID, new_trans_time, price 
        from Room_Type join Room using (type_id) join Booking using (room_id)
        where book_id = new_book_id;
    
        # set Booking paid = 1
        update Booking
        set paid = 1
        where book_id = new_book_id;
    else
        signal sqlstate '45000' set message_text = 'has already been paid';
    end if; 
end$$
delimiter ;

-- call. Add a new transaction record with ID T014, which is for room payment for booking order B010. 
--       The transaction is the executed by staff with ID H005.
--       The transaction time is 2024-05-03 12:00:00.
START TRANSACTION;
call pay_for_room ('T014', 'B010', 'H005', '2024-05-03 12:00:00');
select * from Transactions;
select * from Booking;
ROLLBACK;