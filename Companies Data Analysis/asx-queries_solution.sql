------------------------------------------------------------------
------------------------------SCHEMA------------------------------
------------------------------------------------------------------
-- Address contains the registered address of the company (excluding the zip code and country
-- Zip is the zip code of the Address
-- Country is the incorporation country of the company (same as the country for the Address)
CREATE TABLE Company (
  Code char(3) primary key check (Code ~ '[A-Z]{3}'),
  Name text not null,
  Address text default null,
  Zip varchar(10) default null,
  Country varchar(40) default null
);

-- Person may contain person name, title and/or qualification
CREATE TABLE Executive (
  Code char(3) references Company(Code),
  Person text,
  primary key (Code, Person)
);

CREATE TABLE Category (
  Code char(3) primary key references Company(Code),
  Sector varchar(40) default null,
  Industry varchar(80) default null
);

CREATE TABLE ASX (
  "Date" date,
  Code char(3) references Company(Code),
  Volume integer not null check (Volume >= 0),
  Price numeric not null check (Price > 0.0),
  primary key ("Date", Code)
);

CREATE TABLE Rating (
  Code char(3) references Company(Code),
  Star integer default 3 check (Star > 0 and Star < 6)
);

CREATE TABLE ASXLog (
  "Timestamp" timestamp,
  "Date" date,
  Code char(3) references Company(Code),
  OldVolume integer not null check (OldVolume >= 0),
  OldPrice numeric not null check (OldPrice > 0.0),
  primary key ("Timestamp", "Date", Code)
);

------------------------------------------------------------------
------------------------------QUERIES-----------------------------
------------------------------------------------------------------
--List all the company names (and countries) that are incorporated 
--outside Australia.
create or replace view Q1 (Name, Country) as
    select name, country 
    from Company 
    where country not like 'Australia'
;

--List all the company codes that have more than five executive members on
-- record (i.e., at least six).
create or replace view Q2(Code) as
    select executive.code 
    from executive,company 
    group by company.code , executive.code 
    having company.code=executive.code and count(person) >= 6
;

--List all the company names that are in the sector of "Technology"
create or replace view Q3(Name) as
    select name 
    from company, category 
    where company.code = category.code and category.sector = 'Technology'
;


--Find the number of Industries in each Sector
create or replace view Q4(Sector, Number) as
    select sector, count(industry) 
    from category 
    group by sector
;

--Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".
create or replace view Q5(Name) as
    select person 
    from executive, category 
    where executive.code = category.code and category.sector = 'Technology'
;

--List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.
create or replace view Q6(Name) as
    select name 
    from company, category 
    where company.code=category.code and category.sector = 'Services' and company.zip ~ '^2'
;

--Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).
create or replace view mindates(min, code) as --for each code finding minimum date
    select min("Date"), code
    from asx
    group by code
;

create or replace view newprice as --finding the next price for each code
    select lag(price,1) over (partition by asx.code order by "Date"),asx.code
    from asx, mindates where mindates.min!=asx."Date" and asx.code=mindates.code
;


create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as --excluding dates in view(mindates) and print the answer
    select ASX."Date", ASX.code, volume, asx.price,asx.price, asx.price-newprice.lag, ((asx.price-newprice.lag)/price)*100
    from ASX, newprice, mindates
    where ASX.code=newprice.code and asx.code=mindates.code and asx."Date"!=mindates.min
;

--Find the most active trading stock (the one with the maximum trading 
--volume; if more than one, output all of them) on every trading day. Order 
--your output by "Date" and then by Code.
create or replace view Q8("Date", Code, Volume) as
    select distinct ASX."Date", ASX.Code, volume
    from asx
    group by asx."Date", asx.code
    having volume in(
        select max(volume)
        from asx
        group by asx."Date"
        having asx."Date" in(
            select distinct asx."Date"
            from asx))
    order by "Date", code
; 

--Find the number of companies per Industry. Order your result by Sector and 
--then by Industry.
create or replace view Q9(Sector, Industry, Number) as
    select sector, industry, count(category.code)
    from category
    group by industry, sector
    order by sector,industry
;

--List all the companies (by their Code) that are the only one in their 
--Industry (i.e., no competitors).
create or replace view Q10(Code, Industry) as
    select category.code, category.industry
    from category
    group by category.code
    having industry in (select industry
                        from category
                        group by industry
                        having count(category.code)=1)
    order by(code)
;

--List all sectors ranked by their average ratings in descending order. 
--AvgRating is calculated by finding the average AvgCompanyRating for each 
--sector (where AvgCompanyRating is the average rating of a company).
create or replace view Q11_1(sector, code, AvgCompanyRating) as  --creating a view which gives average of each company's rating.
    select sector, rating.code, avg(star)
    from rating, category
    group by sector, rating.code, category.code, rating.star
    having category.code=rating.code
    order by sector
;

create or replace view Q11(Sector, AvgRating) as  --creating a view which creates the average of all the companies that are in one sector.
    select Q11_1.sector, avg(AvgCompanyRating)
    from Q11_1
    group by Q11_1.sector
    order by avg(AvgCompanyRating)
;
    

--Output the person names of the executives that are 
--affiliated with more than one company.
create or replace view Q12(Name) as
    select executive.person
    from executive
    group by executive.person
    having executive.person in(
        select executive.person
        from executive, company
        group by company, executive.person
        having count(company.code) > 1)
;

--Find all the companies with a registered address in Australia, in a Sector 
--where there are no overseas companies in the same Sector. i.e., they are in 
--Sector that all companies there have local Australia address.
create or replace view Q13(Code, Name, Address, Zip, Sector) as
    select company.code, company.name, company.address, company.zip, category.sector
    from company, category
    where company.code=category.code and sector in(
        select distinct sector
        from category
        where sector not in(
            select  distinct category.sector
            from category
            where category.code in(select company.code 
            from company
            where company.country not like 'Australia')))
    order by company.code
;

--Calculate stock gains based on their prices of the first trading day and 
--last trading day (i.e., the oldest "Date" and the most recent "Date" of the 
--records stored in the ASX table). Order your result by Gain in descending 
--order and then by Code in ascending order.
create or replace view min_max(code, mindate, maxdate) as --creating view for beginning date and ending date
    select asx.code, min(asx."Date"), max(asx."Date") 
    from asx
    group by asx.code
    order by asx.code
;

create or replace view Q14_1(code, BeginPrice) as -- creating view for price on Begining date
    select asx.code, asx.price
    from asx, min_max
    where asx.code=min_max.code AND asx."Date"=min_max.mindate 
;

create or replace view Q14_2(code, EndPrice) as --creating view for price on ending date
    select asx.code, asx.price
    from asx, min_max
    where asx.code=min_max.code AND asx."Date"=min_max.maxdate 
;


create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as --putting the EndPrice and BeginPrice and doing change and gain
    select distinct asx.code, q14_1.BeginPrice, q14_2.EndPrice, (q14_2.EndPrice-q14_1.BeginPrice), ((q14_2.EndPrice-q14_1.BeginPrice)/q14_1.BeginPrice)*100 as Gain
    from asx, q14_1, q14_2
    where q14_1.code=asx.code and q14_2.code=asx.code
    order by Gain desc, asx.code
;



--Create a trigger on the Executive table, to check and disallow any insert or update of a 
--Person in the Executive table to be an executive of more than one company. 
create function q16_func() returns trigger as $$ --function to check if executive is present
    begin 
    if (new.person=(select person from executive where new.person=execitive.person)) then
    return null;
    else return new;
    end if;
    end;
    $$ language plpgsql
;

create trigger q16 before insert or update --trigger on executive
    on executive for each row execute procedure q16_func()
;




