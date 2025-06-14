-- Granting full access on itversity_retail_db to the User itversity_retail_user:
GRANT ALL PRIVILEGES ON DATABASE itversity_retail_db TO itversity_retail_user;


-- 2. NOW, connect to the itversity_retail_db database as a superuser
-- Example: \c itversity_retail_db; (in psql)

-- 3. Grant privileges on the 'public' schema (this is the missing piece for your error)
GRANT USAGE ON SCHEMA public TO itversity_retail_user;
GRANT CREATE ON SCHEMA public TO itversity_retail_user;


-- 4. (Optional but highly recommended) Set default privileges for future objects
--    This ensures that tables/sequences created by this user will also have the right permissions
ALTER DEFAULT PRIVILEGES FOR ROLE itversity_retail_user IN SCHEMA public
    GRANT ALL ON TABLES TO itversity_retail_user;
ALTER DEFAULT PRIVILEGES FOR ROLE itversity_retail_user IN SCHEMA public
    GRANT ALL ON SEQUENCES TO itversity_retail_user;
ALTER DEFAULT PRIVILEGES FOR ROLE itversity_retail_user IN SCHEMA public
    GRANT ALL ON FUNCTIONS TO itversity_retail_user;