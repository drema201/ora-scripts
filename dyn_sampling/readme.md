Please use those script from sqlplus

They do not require any parameters

Just:

sqlplus username/yourpass@ORCL @dyn_sampl_10.sql

or

sqlplus username/yourpass@ORCL @dyn_sampl_10c.sql


@dyn_sampl_10.sql - covers wrong stats case on Global temporary table

@dyn_sampl_10c.sql - covers empty stats case on Global temporary table