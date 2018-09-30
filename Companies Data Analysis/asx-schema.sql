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



--List all the company names (and countries) that are incorporated outside Australia.
    create or replace view Q1(Name, Country) as
      select * 

--List all the company codes that have more than five executive members on record (i.e., at least six).
    create or replace view Q2(Code) as ...

--List all the company names that are in the sector of "Technology"
    create or replace view Q3(Name) as ...

--Find the number of Industries in each Sector
    
    create or replace view Q4(Sector, Number) as ...

--Find all the executives (i.e., their names) that are affiliated with companies in the sector of "Technology". If an executive is affiliated with more than one company, he/she is counted if one of these companies is in the sector of "Technology".
    create or replace view Q5(Name) as ...

--List all the company names in the sector of "Services" that are located in Australia with the first digit of their zip code being 2.
    create or replace view Q6(Name) as ...

--Create a database view of the ASX table that contains previous Price, Price change (in amount, can be negative) and Price gain (in percentage, can be negative). (Note that the first trading day should be excluded in your result.) For example, if the PrevPrice is 1.00, Price is 0.85; then Change is -0.15 and Gain is -15.00 (in percentage but you do not need to print out the percentage sign).
    create or replace view Q7("Date", Code, Volume, PrevPrice, Price, Change, Gain) as ...

--Find the most active trading stock (the one with the maximum trading volume; if more than one, output all of them) on every trading day. Order your output by "Date" and then by Code.
    create or replace view Q8("Date", Code, Volume) as ...

--Find the number of companies per Industry. Order your result by Sector and then by Industry.
    create or replace view Q9(Sector, Industry, Number) as ...

--List all the companies (by their Code) that are the only one in their Industry (i.e., no competitors).
    create or replace view Q10(Code, Industry) as ...

--List all sectors ranked by their average ratings in descending order. AvgRating is calculated by finding the average AvgCompanyRating for each sector (where AvgCompanyRating is the average rating of a company).
    create or replace view Q11(Sector, AvgRating) as ...

--Output the person names of the executives that are affiliated with more than one company.
    create or replace view Q12(Name) as ...

--Find all the companies with a registered address in Australia, in a Sector where there are no overseas companies in the same Sector. i.e., they are in a Sector that all companies there have local Australia address.
    create or replace view Q13(Code, Name, Address, Zip, Sector) as ...

--Calculate stock gains based on their prices of the first trading day and last trading day (i.e., the oldest "Date" and the most recent "Date" of the records stored in the ASX table). Order your result by Gain in descending order and then by Code in ascending order.
    create or replace view Q14(Code, BeginPrice, EndPrice, Change, Gain) as ...

--For all the trading records in the ASX table, produce the following statistics as a database view (where Gain is measured in percentage). AvgDayGain is defined as the summation of all the daily gains (in percentage) then divided by the number of trading days (as noted above, the total number of days here should exclude the first trading day).
    create or replace view Q15(Code, MinPrice, AvgPrice, MaxPrice, MinDayGain, AvgDayGain, MaxDayGain) as ...

--Create a trigger on the Executive table, to check and disallow any insert or update of a Person in the Executive table to be an executive of more than one company. 

--Suppose more stock trading data are incoming into the ASX table. Create a trigger to increase the stock's rating (as Star's) to 5 when the stock has made a maximum daily price gain (when compared with the price on the previous trading day) in percentage within its sector. For example, for a given day and a given sector, if Stock A has the maximum price gain in the sector, its rating should then be updated to 5. If it happens to have more than one stock with the same maximum price gain, update all these stocks' ratings to 5. Otherwise, decrease the stock's rating to 1 when the stock has performed the worst in the sector in terms of daily percentage price gain. If there are more than one record of rating for a given stock that need to be updated, update (not insert) all these records. 

--Stock price and trading volume data are usually incoming data and seldom involve updating existing data. However, updates are allowed in order to correct data errors. All such updates (instead of data insertion) are logged and stored in the ASXLog table. Create a trigger to log any updates on Price and/or Voume in the ASX table and log these updates (only for update, not inserts) into the ASXLog table. Here we assume that Date and Code cannot be corrected and will be the same as their original, old values. Timestamp is the date and time that the correction takes place. Note that it is also possible that a record is corrected more than once, i.e., same Date and Code but different Timestamp.