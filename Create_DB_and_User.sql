-- Creating a Database named: itversity_retail_db isnide the Server PostgreSQL 17:
CREATE DATABASE itversity_retail_db;

--Creating a User itversity_retail_user
CREATE USER itversity_retail_user WITH ENCRYPTED PASSWORD 'doctor11';

-- Granting full access on itversity_retail_db to the User itversity_retail_user:
GRANT ALL PRIVILEGES ON DATABASE itversity_retail_db TO itversity_retail_user;