-- Views

-- 1. To view the detailed information of the staff in Rooms structure, 
--    such as ID, name, job, supervisory job, salary and phone number. 
create view Staff_Infor (ID, name, job, supervisory_job, salary, phone) as
    select ID, staff_name, J.job_name, S.job_name, concat('$', J.salary), phone
    from Staff join (
    Job J left outer join Job S on (J.supervisory_job_id = S.job_id)
    ) on (Staff.job_id = J.job_id)
    where J.struc_name = 'Rooms';


-- 2. To view the room booking information and transactions summaries. 
create view Book_Trans_Infor (book_id, room_id, type_name,
                              check_in_time, check_out_time, paid, 
                              total_transaction_amount, transaction_number) as
    select book_id, room_id, 
        (select Typ.type_name
        from Room R join Room_Type Typ using (type_id)
        where R.room_id = B.room_id), 
        check_in_time, check_out_time, paid,
        (select concat('$', ifnull(sum(amount), 0)) 
        from Transactions T1
        where T1.book_id = B.book_id),
        (select count(*)
        from Transactions T2
        where T2.book_id = B.book_id)
    from Booking B;