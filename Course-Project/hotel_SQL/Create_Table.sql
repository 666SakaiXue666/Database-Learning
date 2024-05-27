-- 1.Structure
create table Structure (
struc_name varchar(10), 
address varchar(10), 
struc_phone char(8),
primary key (struc_name)
);

-- 2.Job
create table Job (
job_id char(4), 
job_name varchar(20),
supervisory_job_id char(4),  # 
struc_name varchar(10),  #
salary numeric(8,2) check (salary > 0),
primary key (job_id),
foreign key (supervisory_job_id) references Job(job_id),
foreign key (struc_name) references Structure (struc_name)
);

-- 3.Staff
create table Staff (
ID char(4), 
job_id char(4),  #
staff_name varchar(20) check (staff_name regexp '^[A-Za-z ]+$'), 
phone char(8), 
primary key (ID),
foreign key (job_id) references Job (job_id)
);

-- 4.Room_Type
create table Room_Type (
type_id char(4), 
type_name varchar(10), 
occupancy numeric (2, 0) check (occupancy > 0), 
bed_num numeric (2, 0) check (bed_num > 0), 
area numeric (5, 2) check (area > 0), 
price numeric (6, 2) check (price > 0),
primary key (type_id)
);

-- 5.Room
create table Room (
room_id char(4),
type_id char(4),  #
room_phone char(4),
primary key (room_id),
foreign key (type_id) references Room_type (type_id)
);

-- 6.Booking
create table Booking (
book_id char(4), 
room_id char(4),  #
check_in_time datetime, 
check_out_time datetime,
paid bool,
primary key (book_id),
foreign key (room_id) references Room (room_id)
);

-- 7.Customer
create table Customer (
ID char(4), 
book_id char(4),  #
customer_name varchar(8),
phone char(8), 
primary key (ID),
foreign key (book_id) references Booking (book_id),
CONSTRAINT check_customer_name CHECK (customer_name REGEXP '^[A-Za-z ]+$')
);

-- 8.Transactions
create table Transactions (
trans_id char(4),
book_id char(4),  #
struc_name  varchar(8),  #
execute_ID char(4),  #
trans_time datetime, 
amount numeric(10,4),
primary key (trans_id),
foreign key (book_id) references Booking (book_id),
foreign key (struc_name) references Structure (struc_name),
foreign key (execute_ID) references Staff (ID)
);