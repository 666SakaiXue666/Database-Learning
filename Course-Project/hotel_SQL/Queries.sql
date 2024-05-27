-- Reasonable Queries

-- 1. Find the highest paid staff. 
with Staff_Job as(
    select *
    from Staff join Job using (job_id))
select ID, staff_name
from Staff_job
where salary = (select MAX(salary) from Staff_Job);

-- 2. Calculate the average salary for each structure
with Staff_Job as(
    select *
    from Staff join Job using (job_id))
select struc_name, avg(salary) as average_salary
from Staff_Job
group by struc_name;

-- 3. Display the salaries of all staffs and sort them in descending order. 
select s.staff_name, j.salary
from Staff s
join Job j on s.job_id = j.job_id
order by j.salary desc;

-- 4. Find the rooms with the top 3 highest transaction count in the paid room booking record.
select t.type_name, count(*) as transaction_num
from Room_Type t
join Room r on r.type_id = t.type_id
join Booking b on b.room_id = r.room_id
where b.paid = 1
group by t.type_name
order by transaction_num desc
limit 3;

-- 5. Query the room IDs of ‘Economy’ type.
select r.room_id, t.type_name
from Room r
join Room_Type t on t.type_id = r.type_id
where t.type_name = 'Economy';

-- 6. Query the total transaction amount of different structures. 
select struc_name, ifnull(sum(amount), 0) as total_amount
from Structure left outer join Transactions using (struc_name)
group by struc_name;
-- or
select struc_name, (select ifnull(sum(amount), 0)
                    from Transactions T
                    where T.struc_name = S.struc_name) as total_amount
from Structure S;

-- 7. Find staff Simon’s job and his/her supervisor and supervisor’s job. 
select J.job_name, S.job_name as supervisory_job, stf_s.staff_name as supervisor, J.struc_name
from (Job J left outer join Job S on J.supervisory_job_id = S.job_id) 
join Staff stf_j on stf_j.job_id = J.job_id
join Staff stf_s on stf_s.job_id = S.job_id
where stf_j.staff_name = 'Simon';

-- 8. Find staff Simon’s job and his/her supervisees and the jobs of supervisees.
select J.job_name, Sed.job_name as supervised_job, stf_sed.staff_name as supervisee, J.struc_name
from (Job J left outer join Job Sed on J.job_id = Sed.supervisory_job_id) 
join Staff stf_j on stf_j.job_id = J.job_id
join Staff stf_sed on stf_sed.job_id = Sed.job_id
where stf_j.staff_name = 'Simon';

-- 9. Find the job ID, job name, structure and salary, where the salary for this job is greater then the 
--    salary for all jobs in Rooms structure. 
select job_id, job_name, struc_name, salary
from Job
where salary > all (select salary
                    from Job
                    where struc_name = 'Rooms');

-- 10. Find the staffs whose names start with ‘Jo’, or have a length of 7 and end with ‘ki’.
select *
from Staff
where staff_name like 'Jo%'
or staff_name like '_____ki';

-- 11. Find the staffs with same name in the same structure. 
select ID, staff_name, struc_name
from Staff S1 join Job J1 using (job_id)
where exists (select *
              from Staff S2 join Job J2 using (job_id)
              where J2.struc_name = J1.struc_name
              and S2.staff_name = S1.staff_name
              and S2.ID != S1.ID);

-- 12. Find all the time period that have been booked for the rooms satisfying the certain conditions 
--     (occupancy and bed number) within a specific date range. 
set @new_occupancy = 2;
set @new_bed_num = 2;
set @new_check_in_date = '2024-04-29';
set @new_check_out_date = '2024-05-01';
select room_id, check_in_time, check_out_time, paid
from Booking
where room_id in (
    select room_id 
    from Room join Room_Type using (type_id)
where occupancy = @new_occupancy and bed_num = @new_bed_num
)
and not(
    date(check_out_time) < @new_check_in_date
    or
    date(check_in_time) > @new_check_out_date
)
order by room_id, check_in_time;

-- 13. Find all the rooms that have not been booked within a given period of time.
set @new_check_in_time = '2024-04-29 13:00:00';
set @new_check_out_time = '2024-04-29 14:00:00';
select room_id
from Room R
where not exists(
select *
from Booking
where Booking.room_id = R.room_id
and not(
@new_check_in_time > check_out_time 
or @new_check_out_time < check_in_time));
