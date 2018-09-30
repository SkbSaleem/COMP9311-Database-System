-- COMP9311 16s2 Assignment 1
-- Schema for KensingtonCars
--
-- Written by Saqib Saleem
-- Student ID: z5106444

create domain URLType as
	varchar(100) check (value like 'http://%');

create domain EmailType as
	varchar(100) check (value like '%@%.%');

create domain PhoneType as
	char(10) check (value ~ '[0-9]{10}');

create domain CarLicenseType as
        char(6) check (value ~ '[0-9A-Za-z]{6}');

create domain OptionType as varchar(12)
	check (value in ('sunroof','moonroof','GPS','alloy wheels','leather'));

create domain VINType as char(17) check(value !~'[OoIiQq]');

-- EMPLOYEE

create table Employee (
	EID serial,
    TFN text not null check (length(TFN)=9),
    Salary integer not null check (Salary > 0),
	firstname text check(length(firstname)=50) not null,
	lastname text not null check(length(lastname)<50),
	primary key (EID)
);

create table Admin (
	EID integer not null references employee (EID),
	primary key (EID) 
);

create table Mechanic (
	EID integer not null references Employee (EID),
	license char(8) not null check (length(license)=8),
	primary key (EID) 
);

create table Salesman (
	EID integer not null references employee (EID),
	commrate numeric(2,2) not null check (commrate>0.05 and commrate<0.20),
	primary key (EID)
);


-- CLIENT

create table Client (
	CID serial not null,
	phone PhoneType not null,
	email EmailType,
	address text check (length(address)<200) not null,
	name text check (length(name)<100) not null,
	primary key (CID)
);

create table Company (
	CID integer references Client (CID),
	ABN text check (length(abn)=11),
	url URLType,
	primary key (CID)
);	


-- CAR
create table Car (
	VIN VINType not null,
	year integer check (year<3000 and year >1969) not null,
	model text check(length(model)<50) not null,
	manufacturer text check(length(manufacturer)<50) not null,
	options OptionType,
	primary key (VIN)
);
	
create table NewCar (
	VIN VINType not null references Car (VIN),
	cost numeric(8,2),
	charges numeric(8,2),
	primary key (VIN)
);

create table UsedCar (
	VIN VINType not null references Car (VIN),
	platenumber CarLicenseType,
	primary key (VIN)
);

--Buy, Sell and Repair

 create table RepairJob (
 	description text check (length(description)<251),
 	"number" integer check("number">0 and "number"<1000),
 	parts numeric(8,2),
 	work numeric(8,2),
 	VIN VINType not null,
 	foreign key (VIN) references UsedCar (VIN),
 	primary key ("number",VIN)
 );


create table DoesJob (
	EID integer not null,
 	"number" integer check("number">0 and "number"<1000),
	VIN VINType not null,
	foreign key ("number",VIN) references RepairJob ("number",VIN),
	foreign key (EID) references Mechanic (EID),
	primary key (EID, "number", VIN)
);


create table Buys (
	price numeric(8,2) check(price>0), -------should be positive
	"date" date,
	commission numeric(8,2) check(commission>0),  -------should be positive
	EID integer not null,
	CID integer not null,
	VIN VINType not null,
	foreign key (EID) references Salesman (EID),
	foreign key (CID) references Client (CID),
	foreign key (VIN) references UsedCar (VIN),
	primary key (EID, VIN, CID)
);

create table Sells (
	"date" date,
	price numeric(8,2) check(price>0),
	commission numeric(8,2) check(commission>0),
	EID integer not null,
	CID integer not null,
	VIN VINType not null,
	foreign key (EID) references Salesman (EID),
	foreign key (CID) references Client (CID),
	foreign key (VIN) references UsedCar (VIN),
	primary key (EID, VIN, CID)
);

create table SellsNew (
	"date" date,
	price numeric(8,2) check(price>0),
	platenumber CarLicenseType,
	commission numeric(8,2) check(commission>0),
	EID integer not null,
	CID integer not null,
	VIN VINType not null,
	foreign key (EID) references Salesman (EID),
	foreign key (CID) references Client (CID),
	foreign key (VIN) references NewCar (VIN),
	primary key (EID, VIN, CID)
);

