DROP TABLE IF EXISTS courses;

CREATE TABLE courses(
			 course_id SERIAL PRIMARY KEY,
			 course_name VARCHAR(60),
			 course_author VARCHAR(40),
			 course_status VARCHAR(9),
		     course_published_dt DATE
);



INSERT INTO courses
    (course_name, course_author, course_status, course_published_dt)
VALUES
    ('Programming using Python', 'Bob Dillon', 'published', '2020-09-30'),
    ('Data Engineering using Python', 'Bob Dillon', 'published', '2020-07-15'),
    ('Data Engineering using Scala', 'Elvis Presley', 'draft', null),
    ('Programming using Scala' , 'Elvis Presley' , 'published' , '2020-05-12'),
    ('Programming using Java' , 'Mike Jack' , 'inactive' , '2020-08-10'),
    ('Web Applications - Python Flask' , 'Bob Dillon' , 'inactive' , '2020-07-20'),
    ('Web Applications - Java Spring' , 'Bob Dillon' , 'draft' , null),
    ('Pipeline Orchestration - Python' , 'Bob Dillon' , 'draft' , null),
    ('Streaming Pipelines - Python' , 'Bob Dillon' , 'published' , '2020-10-05'),
    ('Web Applications - Scala Play' , 'Elvis Presley' , 'inactive' , '2020-09-30'),
    ('Web Applications - Python Django' , 'Bob Dillon' , 'published' , '2020-06-23'),
    ('Server Automation - Ansible' , 'Uncle Sam' , 'published' , '2020-07-05');

-- Question 1: Get all the details of the courses which are in `inactive` or `draft` state.
SELECT * 
FROM courses
WHERE course_status IN ('inactive', 'drfat' );

-- Question 2: Get all the details of the courses which are related to `Python` or `Scala`.
SELECT * 
FROM courses 
WHERE course_name ILIKE '%python%' OR course_name ILIKE '%scala%';

-- Question 3: Get count of courses by `course_status`. The output should contain `course_status` and `course_count`.
SELECT course_status, count(course_status)
FROM courses
GROUP BY course_status;

-- Question 4: Get count of `published` courses by `course_author`. The output should contain `course_author` and `course_count`.
SELECT
    course_author,
    COUNT(course_id) AS course_count
FROM
    courses
WHERE
    course_status = 'published'
GROUP BY
    course_author
ORDER BY
    course_author; -- Optional: to get a sorted output


-- Question 5: Get all the details of `Python` or `Scala` related courses in `draft` status.
SELECT *
FROM courses
WHERE course_status = 'draft'
	AND (course_name ILIKE '%python' 
	OR course_name ILIKE '%scala%');