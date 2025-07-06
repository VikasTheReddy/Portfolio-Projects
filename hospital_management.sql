create database hospital_management;
use hospital_management;

-- create patients table (1nf: atomic values, no repeating groups)
create table patients (
    patient_id int primary key auto_increment,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    dob date not null,
    phone varchar(15)
);

-- create doctors table (1nf: atomic values)
create table doctors (
    doctor_id int primary key auto_increment,
    first_name varchar(50) not null,
    last_name varchar(50) not null,
    specialty varchar(100) not null
);

-- create treatments table (2nf: no partial dependencies)
create table treatments (
    treatment_id int primary key auto_increment,
    patient_id int,
    doctor_id int,
    diagnosis varchar(100) not null,
    treatment_date date not null,
    foreign key (patient_id) references patients(patient_id),
    foreign key (doctor_id) references doctors(doctor_id)
);

-- create appointments table (3nf: no transitive dependencies)
create table appointments (
    appointment_id int primary key auto_increment,
    patient_id int,
    doctor_id int,
    appointment_date date not null,
    appointment_time time not null,
    foreign key (patient_id) references patients(patient_id),
    foreign key (doctor_id) references doctors(doctor_id)
);

-- trigger to limit doctor to 10 appointments per day
delimiter //
create trigger limit_appointments
before insert on appointments
for each row
begin
    declare appt_count int;
    select count(*) into appt_count
    from appointments
    where doctor_id = new.doctor_id
    and appointment_date = new.appointment_date;
    if appt_count >= 10 then
        signal sqlstate '45000'
        set message_text = 'doctor has reached the maximum of 10 appointments for this day';
    end if;
end //
delimiter ;

-- sample data for testing
insert into patients (first_name, last_name, dob, phone) values
('john', 'doe', '1985-03-15', '555-0101'),
('jane', 'smith', '1990-07-22', '555-0102'),
('alice', 'brown', '1978-11-30', '555-0103');

insert into doctors (first_name, last_name, specialty) values
('emma', 'wilson', 'cardiology'),
('liam', 'johnson', 'neurology'),
('olivia', 'davis', 'pediatrics');

insert into treatments (patient_id, doctor_id, diagnosis, treatment_date) values
(1, 1, 'hypertension', '2025-07-01'),
(2, 2, 'migraine', '2025-07-02'),
(3, 3, 'flu', '2025-07-03'),
(1, 2, 'migraine', '2025-07-04');

insert into appointments (patient_id, doctor_id, appointment_date, appointment_time) values
(1, 1, '2025-07-10', '09:00:00'),
(2, 1, '2025-07-10', '10:00:00'),
(3, 2, '2025-07-11', '11:00:00');

-- query to generate report of patients diagnosed with a specific disease (e.g., migraine)
select p.first_name, p.last_name, p.dob, t.diagnosis, t.treatment_date, d.first_name as doctor_first_name, d.last_name as doctor_last_name
from patients p
natural join treatments t
natural join doctors d
where t.diagnosis = 'migraine';