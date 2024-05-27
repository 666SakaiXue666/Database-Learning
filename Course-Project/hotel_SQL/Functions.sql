-- Functions

-- 1. Get the room with the longest total booking time during the given date period.  
delimiter $$
create function max_room_hours_period (input_start_date char(10),
                                       input_end_date char(10)) 
returns char(4)
reads sql data
begin
    declare max_hours_id char(4);
    declare input_start_time datetime;
    declare input_end_time datetime;
    select concat(str_to_date(input_start_date, '%Y-%m-%d'), ' 00:00:00')  into input_start_time;
    select concat(str_to_date(input_end_date, '%Y-%m-%d'), ' 23:59:59') into input_end_time;
    
    with union_period_books as (
        (select room_id, book_id, check_in_time as s_time, check_out_time as e_time
        from Booking
        where input_start_time <= check_in_time 
        and check_out_time <= input_end_time)
        union
        (select room_id, book_id, input_start_time as s_time, check_out_time as e_time
        from Booking
        where check_in_time < input_start_time
        and input_start_time < check_out_time
        and check_out_time <= input_end_time)
        union
        (select room_id, book_id, check_in_time as s_time, input_end_time as e_time
        from Booking
        where input_start_time <= check_in_time 
        and check_in_time < input_end_time
        and  input_end_time < check_out_time)
        union
        (select room_id, book_id, input_start_time as s_time, input_end_time as e_time
        from Booking
        where check_in_time < input_start_time 
        and  input_end_time < check_out_time)
    ),
    sum_group_hours as (
        select room_id, sum(timestampdiff(hour, s_time, e_time)) as sum_hours
        from union_period_books
        group by room_id
    )
    select room_id into max_hours_id
    from sum_group_hours
    where sum_hours = (select max(sum_hours) from sum_group_hours);
    return max_hours_id;
end$$
delimiter ;

-- call. get the room with the longest total booking time between 2024-04-28 and 2024-04-30
select max_room_hours_period('2024-04-28', '2024-04-30');



-- 2. Get the total transaction amount of a specific structure during a certain period of time.
delimiter $$
create function total_struc_trans_period (input_struc_name char(20),
                                          input_start_time char(19),
                                          input_end_time char(19)) 
returns varchar(20)
reads sql data
begin
    declare total_amount varchar(20);
    declare input_start_time_ datetime;
    declare input_end_time_ datetime;
    
    set input_start_time_ = str_to_date(input_start_time, '%Y-%m-%d %H:%i:%s');
    
    if input_end_time is NULL or input_end_time = '' then
        set input_end_time_ = date_format(now(), '%Y-%m-%d %H:%i:%s');
    else
        set input_end_time_ = str_to_date(input_end_time, '%Y-%m-%d %H:%i:%s');
    end if;
    
    select concat(sum(amount), '$') into total_amount
    from Transactions
    where struc_name = input_struc_name
    and trans_time >= input_start_time_ and trans_time <= input_end_time_;
    
    return total_amount;
end$$
delimiter ;

-- call. get the total transaction amount of Rooms structure
--       during the time period from 2024-04-26 00:00:00 to 2024-05-01 23:59:59
select total_struc_trans_period('Rooms', '2024-04-26 00:00:00', '2024-05-01 23:59:59');
