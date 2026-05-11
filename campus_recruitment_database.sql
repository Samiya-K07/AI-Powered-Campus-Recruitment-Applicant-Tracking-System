-- Creating Tables
CREATE TABLE Accounts (
    account_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role VARCHAR(10) NOT NULL CHECK (role IN ('student', 'recruiter')),
    created_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE Accounts ALTER COLUMN created_at SET NOT NULL;

CREATE TABLE Companies (
    company_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    industry VARCHAR(100),
    location VARCHAR(150)
);

CREATE TABLE Students (
    student_id INT PRIMARY KEY REFERENCES Accounts(account_id),
    cgpa DECIMAL(3,2) CHECK (cgpa >= 0.0 AND cgpa <= 4.0),
    major VARCHAR(100),
    graduation_year INT
);

CREATE TABLE Recruiters (
    recruiter_id INT PRIMARY KEY REFERENCES Accounts(account_id),
    company_id INT REFERENCES Companies(company_id)
);

ALTER TABLE Recruiters 
ALTER COLUMN company_id SET NOT NULL;

CREATE TABLE Skills (
    skill_id SERIAL PRIMARY KEY,
    skill_name VARCHAR(100) NOT NULL UNIQUE,
    category VARCHAR(20) CHECK (category IN ('technical', 'soft', 'domain'))
);

ALTER TABLE Skills ALTER COLUMN category SET NOT NULL;

CREATE TABLE Job_Posts (
    job_id SERIAL PRIMARY KEY,
    company_id INT NOT NULL REFERENCES Companies(company_id),
    title VARCHAR(150) NOT NULL,
    description TEXT,
    min_cgpa DECIMAL(3,2) CHECK (min_cgpa >= 0.0 AND min_cgpa <= 4.0),
    deadline DATE,
    salary DECIMAL(10,2),
    status VARCHAR(10) DEFAULT 'active' CHECK (status IN ('active', 'closed', 'draft')),
    posted_at TIMESTAMP DEFAULT NOW()
);

ALTER TABLE Job_Posts
ALTER COLUMN deadline SET NOT NULL;

ALTER TABLE Job_Posts
ALTER COLUMN salary SET NOT NULL;

ALTER TABLE Job_Posts
ALTER COLUMN min_cgpa SET NOT NULL;

ALTER TABLE Job_Posts ALTER COLUMN status SET NOT NULL;

ALTER TABLE Job_Posts ALTER COLUMN posted_at SET NOT NULL;

CREATE TABLE Student_Skills (
    student_id INT REFERENCES Students(student_id),
    skill_id INT REFERENCES Skills(skill_id),
    proficiency_level VARCHAR(15) DEFAULT 'beginner' CHECK (proficiency_level IN ('beginner', 'intermediate', 'advanced')),
    PRIMARY KEY (student_id, skill_id)
);

ALTER TABLE Student_Skills ALTER COLUMN proficiency_level SET NOT NULL;

CREATE TABLE Job_Required_Skills (
    job_id INT REFERENCES Job_Posts(job_id),
    skill_id INT REFERENCES Skills(skill_id),
    weight DECIMAL(3,2) DEFAULT 1.0 CHECK (weight IN (0.5, 1.0)),
    PRIMARY KEY (job_id, skill_id)
);

CREATE TABLE Applications (
    application_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL REFERENCES Students(student_id),
    job_id INT NOT NULL REFERENCES Job_Posts(job_id),
    match_score DECIMAL(5,2),
    rank_position INT,
    status VARCHAR(15) DEFAULT 'submitted' CHECK (status IN ('submitted', 'shortlisted', 'rejected', 'accepted')),
    apply_date TIMESTAMP DEFAULT NOW(),
    UNIQUE (student_id, job_id)
);

ALTER TABLE Applications ALTER COLUMN apply_date SET NOT NULL;

CREATE TABLE Resumes (
    resume_id SERIAL PRIMARY KEY,
    student_id INT NOT NULL UNIQUE REFERENCES Students(student_id),
    raw_text TEXT,
    parsed_skills TEXT,
    experience_years INT,
    last_parsed_at TIMESTAMP
);

CREATE TABLE AuditLog (
    log_id SERIAL PRIMARY KEY,
    action VARCHAR(100),
    entity VARCHAR(100),
    entity_id INT,
    performed_by INT REFERENCES Accounts(account_id),
    timestamp TIMESTAMP DEFAULT NOW()
);

ALTER TABLE AuditLog ALTER COLUMN timestamp SET NOT NULL;

SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public'
ORDER BY table_name;

-- Inserting Dummy Data
INSERT INTO Accounts (name, email, password_hash, role) VALUES
('Sara Ahmed', 'sara@student.com', 'hash_placeholder', 'student'),
('Ali Hassan', 'ali@student.com', 'hash_placeholder', 'student'),
('Zara Khan', 'zara@student.com', 'hash_placeholder', 'student'),
('Omar Malik', 'omar@recruiter.com', 'hash_placeholder', 'recruiter'),
('Hina Javed', 'hina@recruiter.com', 'hash_placeholder', 'recruiter'),
('Bilal Sheikh', 'bilal@recruiter.com', 'hash_placeholder', 'recruiter');

SELECT account_id, name, role FROM Accounts ORDER BY account_id;

INSERT INTO Companies (name, industry, location) VALUES
('TechCorp', 'Technology', 'Karachi'),
('FinanceHub', 'Finance', 'Lahore'),
('MediaWorks', 'Media', 'Islamabad');

SELECT * FROM Companies;

INSERT INTO Students (student_id, cgpa, major, graduation_year) VALUES
(1, 3.8, 'Computer Science', 2025),
(2, 3.1, 'Software Engineering', 2025),
(3, 2.4, 'Business Administration', 2026);

SELECT s.student_id, a.name, s.cgpa, s.major
FROM Students s
JOIN Accounts a ON s.student_id = a.account_id;

INSERT INTO Recruiters (recruiter_id, company_id) VALUES
(4, 1),
(5, 2),
(6, 3);

SELECT r.recruiter_id, a.name, c.name AS company
FROM Recruiters r
JOIN Accounts a ON r.recruiter_id = a.account_id
JOIN Companies c ON r.company_id = c.company_id;

INSERT INTO Skills (skill_name, category) VALUES
('Python', 'technical'),
('SQL', 'technical'),
('Data Analysis', 'technical'),
('Machine Learning', 'technical'),
('JavaScript', 'technical'),
('Communication', 'soft'),
('Teamwork', 'soft'),
('Problem Solving', 'soft'),
('Finance', 'domain'),
('Marketing', 'domain');

SELECT * FROM Skills ORDER BY skill_id;

INSERT INTO Job_Posts (company_id, title, description, min_cgpa, deadline, salary, status) VALUES
(1, 'Junior Python Developer',
'Build and maintain backend systems using Python. Work with databases and APIs.',
3.0, '2027-12-31', 85000.00, 'active'),

(2, 'Financial Analyst',
'Analyze financial data, prepare reports, and support investment decisions.',
2.8, '2027-12-31', 90000.00, 'active'),

(3, 'Marketing Coordinator',
'Plan and execute marketing campaigns. Coordinate with media and creative teams.',
2.5, '2027-12-31', 70000.00, 'active');

SELECT job_id, title, min_cgpa, status FROM Job_Posts;

-- Sara (student_id = 1): strong technical profile
INSERT INTO Student_Skills (student_id, skill_id, proficiency_level) VALUES
(1, 1, 'advanced'), -- Python
(1, 2, 'advanced'), -- SQL
(1, 3, 'intermediate'), -- Data Analysis
(1, 6, 'intermediate'); -- Communication

-- Ali (student_id = 2): moderate technical profile
INSERT INTO Student_Skills (student_id, skill_id, proficiency_level) VALUES
(2, 1, 'intermediate'), -- Python
(2, 2, 'beginner'), -- SQL
(2, 7, 'advanced'), -- Teamwork
(2, 8, 'intermediate'); -- Problem Solving

-- Zara (student_id = 3): non-technical profile
INSERT INTO Student_Skills (student_id, skill_id, proficiency_level) VALUES
(3, 9,  'intermediate'), -- Finance
(3, 10, 'advanced'), -- Marketing
(3, 6,  'advanced'); -- Communication

SELECT a.name, sk.skill_name, ss.proficiency_level
FROM Student_Skills ss
JOIN Students s ON ss.student_id = s.student_id
JOIN Accounts a ON s.student_id  = a.account_id
JOIN Skills sk ON ss.skill_id   = sk.skill_id
ORDER BY a.name;

-- Job 1: Junior Python Developer
INSERT INTO Job_Required_Skills (job_id, skill_id, weight) VALUES
(1, 1, 1.0), -- Python (required)
(1, 2, 1.0), -- SQL (required)
(1, 3, 0.5), -- Data Analysis (preferred)
(1, 8, 0.5); -- Problem Solving (preferred)

-- Job 2: Financial Analyst
INSERT INTO Job_Required_Skills (job_id, skill_id, weight) VALUES
(2, 9, 1.0), -- Finance (required)
(2, 3, 1.0), -- Data Analysis (required)
(2, 6, 0.5), -- Communication (preferred)
(2, 2, 0.5); -- SQL (preferred)

-- Job 3: Marketing Coordinator
INSERT INTO Job_Required_Skills (job_id, skill_id, weight) VALUES
(3, 10, 1.0), -- Marketing (required)
(3, 6, 1.0), -- Communication (required)
(3, 7, 0.5); -- Teamwork (preferred)

SELECT jp.title, sk.skill_name, jrs.weight
FROM Job_Required_Skills jrs
JOIN Job_Posts jp ON jrs.job_id = jp.job_id
JOIN Skills sk ON jrs.skill_id = sk.skill_id
ORDER BY jp.title;

-- Sara applies to Job 1 and Job 2
INSERT INTO Applications (student_id, job_id, status) VALUES
(1, 1, 'submitted'),
(1, 2, 'submitted');

-- Ali applies to Job 1 and Job 3
INSERT INTO Applications (student_id, job_id, status) VALUES
(2, 1, 'submitted'),
(2, 3, 'submitted');

SELECT a.name AS student, jp.title AS job, app.status, app.match_score
FROM Applications app
JOIN Students s ON app.student_id = s.student_id
JOIN Accounts a ON s.student_id = a.account_id
JOIN Job_Posts jp ON app.job_id = jp.job_id
ORDER BY a.name;

INSERT INTO Resumes (student_id, raw_text, parsed_skills, experience_years) VALUES
(1,
'Sara Ahmed. Computer Science graduate. Experienced in Python and SQL development. Worked as a data analyst intern from June 2023 to August 2024. Proficient in communication and team collaboration.',
'["Python", "SQL", "Data Analysis", "Communication"]',
1),

(2,
'Ali Hassan. Software Engineering student. Has worked on Python projects and basic SQL queries. Completed a problem solving and teamwork workshop. Internship from January 2024 to June 2024.',
'["Python", "SQL", "Teamwork", "Problem Solving"]',
0),

(3,
'Zara Khan. Business Administration student. Strong background in Finance and Marketing. Excellent communication skills. No formal work experience yet.',
'["Finance", "Marketing", "Communication"]',
0);

SELECT a.name, r.experience_years, r.parsed_skills
FROM Resumes r
JOIN Students s ON r.student_id = s.student_id
JOIN Accounts a ON s.student_id = a.account_id;

SELECT 'Accounts' AS table_name, COUNT(*) AS rows FROM Accounts UNION ALL
SELECT 'Companies', COUNT(*) FROM Companies UNION ALL
SELECT 'Students', COUNT(*) FROM Students UNION ALL
SELECT 'Recruiters', COUNT(*) FROM Recruiters UNION ALL
SELECT 'Skills', COUNT(*) FROM Skills UNION ALL
SELECT 'Job_Posts', COUNT(*) FROM Job_Posts UNION ALL
SELECT 'Student_Skills', COUNT(*) FROM Student_Skills UNION ALL
SELECT 'Job_Required_Skills', COUNT(*) FROM Job_Required_Skills UNION ALL
SELECT 'Applications', COUNT(*) FROM Applications UNION ALL
SELECT 'Resumes', COUNT(*) FROM Resumes;

-- Stored Procedures
DELETE FROM Applications;
SELECT COUNT(*) FROM Applications;

-- Procedure 1: Apply_For_Job
CREATE OR REPLACE FUNCTION Apply_For_Job(
    p_student_id INT,
    p_job_id INT
)
RETURNS TEXT AS $$
DECLARE
    v_deadline DATE;
    v_min_cgpa DECIMAL(3,2);
    v_student_cgpa DECIMAL(3,2);
    v_already_applied INT;
    v_job_status VARCHAR(10);
BEGIN
    -- Check if student already applied to this job
    SELECT COUNT(*) INTO v_already_applied
    FROM Applications
    WHERE student_id = p_student_id AND job_id = p_job_id;

    IF v_already_applied > 0 THEN
        RETURN 'ERROR: You have already applied to this job!';
    END IF;

    -- Get job details
    SELECT deadline, min_cgpa, status
    INTO v_deadline, v_min_cgpa, v_job_status
    FROM Job_Posts
    WHERE job_id = p_job_id;

    -- Check if job is active
    IF v_job_status != 'active' THEN
        RETURN 'ERROR: This job is not currently accepting applications!';
    END IF;

    -- Check if deadline has passed
    IF v_deadline < CURRENT_DATE THEN
    	RETURN 'ERROR: This job posting has expired!';
    END IF;

    -- Get student CGPA
    SELECT cgpa INTO v_student_cgpa
    FROM Students
    WHERE student_id = p_student_id;

    -- If CGPA too low insert as rejected immediately
    IF v_student_cgpa < v_min_cgpa THEN
    	INSERT INTO Applications (student_id, job_id, status)
        VALUES (p_student_id, p_job_id, 'rejected');
        RETURN 'REJECTED: Your CGPA does not meet the minimum requirement for this job!';
    END IF;

    -- All checks passed => insert as submitted
    INSERT INTO Applications (student_id, job_id, status)
    VALUES (p_student_id, p_job_id, 'submitted');

    RETURN 'SUCCESS: Application submitted successfully!';

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

--Procedure 2: Calculate_Match_Score
CREATE OR REPLACE FUNCTION Calculate_Match_Score(
    p_application_id INT
)
RETURNS VOID AS $$
DECLARE
    v_student_id INT;
    v_job_id INT;
    v_student_cgpa DECIMAL(3,2);
    v_experience_years INT;
    v_total_weight DECIMAL(10,2) := 0;
    v_matched_weight DECIMAL(10,2) := 0;
    v_skill_score DECIMAL(10,4) := 0;
    v_cgpa_score DECIMAL(10,4) := 0;
    v_exp_score DECIMAL(10,4) := 0;
    v_final_score DECIMAL(5,2) := 0;
    v_app_status VARCHAR(15);
BEGIN
    -- Get student_id, job_id and status from this application
    SELECT student_id, job_id, status
    INTO v_student_id, v_job_id, v_app_status
    FROM Applications
    WHERE application_id = p_application_id;

    -- Do not score rejected applications
    IF v_app_status = 'rejected' THEN
        RETURN;
    END IF;

    -- Get student CGPA
    SELECT cgpa INTO v_student_cgpa
    FROM Students
    WHERE student_id = v_student_id;

    -- Get student experience years (default 0 if no resume exists yet)
    SELECT COALESCE(experience_years, 0)
    INTO v_experience_years
    FROM Resumes
    WHERE student_id = v_student_id;

    -- Get total weight of all required skills for this job
    SELECT COALESCE(SUM(weight), 0)
    INTO v_total_weight
    FROM Job_Required_Skills
    WHERE job_id = v_job_id;

    -- Get matched weight (skills student has that the job requires)
    SELECT COALESCE(SUM(jrs.weight), 0)
    INTO v_matched_weight
    FROM Job_Required_Skills jrs
    JOIN Student_Skills ss
    	ON jrs.skill_id = ss.skill_id
    	AND ss.student_id = v_student_id
    WHERE jrs.job_id = v_job_id;

    -- Calculate each component (all between 0 and 1)
    IF v_total_weight > 0 THEN
        v_skill_score := v_matched_weight / v_total_weight;
    END IF;

    v_cgpa_score := v_student_cgpa / 4.0;
    v_exp_score := LEAST(v_experience_years::DECIMAL / 5.0, 1.0);

    -- Final score out of 100
    v_final_score := ROUND(
        ((0.50 * v_skill_score) +
        (0.30 * v_cgpa_score) +
        (0.20 * v_exp_score)) * 100, 2
    );

    -- Write score to Applications
    UPDATE Applications
    SET match_score = v_final_score
    WHERE application_id = p_application_id;

    -- Update rank positions for all non-rejected applications for this job
    -- Ranked by: score DESC, then CGPA DESC, then apply_date ASC
    WITH ranked AS (
        SELECT
 			app.application_id,
            ROW_NUMBER() OVER (
                ORDER BY
                    app.match_score DESC NULLS LAST,
                    s.cgpa DESC,
                    app.apply_date ASC
            ) AS new_rank
        FROM Applications app
        JOIN Students s ON app.student_id = s.student_id
        WHERE app.job_id = v_job_id
          AND app.status != 'rejected'
    )
    UPDATE Applications
    SET rank_position = ranked.new_rank
    FROM ranked
    WHERE Applications.application_id = ranked.application_id;

END;
$$ LANGUAGE plpgsql;

-- Procedure 3: Generate_Job_Recommendations
CREATE OR REPLACE FUNCTION Generate_Job_Recommendations(
    p_student_id INT
)
RETURNS TABLE (
    rec_job_id INT,
    rec_title VARCHAR(150),
    rec_company VARCHAR(100),
    rec_salary DECIMAL(10,2),
    rec_deadline DATE,
    rec_fit_score DECIMAL(5,2)
) AS $$
DECLARE
    v_student_cgpa DECIMAL(3,2);
BEGIN
    SELECT cgpa INTO v_student_cgpa
    FROM Students
    WHERE student_id = p_student_id;

    RETURN QUERY
    SELECT
        jp.job_id,
        jp.title,
        c.name,
        jp.salary,
        jp.deadline,
        ROUND(
            COALESCE(
                SUM(jrs.weight * CASE WHEN ss.skill_id IS NOT NULL THEN 1 ELSE 0 END) / NULLIF(SUM(jrs.weight), 0), 0
            ) * 100, 2
        )
    FROM Job_Posts jp
    JOIN Companies c
        ON jp.company_id = c.company_id
    JOIN Job_Required_Skills jrs
        ON jp.job_id = jrs.job_id
    LEFT JOIN Student_Skills ss
        ON jrs.skill_id = ss.skill_id
        AND ss.student_id = p_student_id
    WHERE jp.status = 'active'
        AND jp.deadline >= CURRENT_DATE
        AND jp.min_cgpa <= v_student_cgpa
        AND jp.job_id NOT IN (
            SELECT a.job_id FROM Applications a
            WHERE a.student_id = p_student_id
        )
    GROUP BY jp.job_id, jp.title, c.name, jp.salary, jp.deadline
    ORDER BY rec_fit_score DESC
    LIMIT 5;

END;
$$ LANGUAGE plpgsql;

-- Procedure 4: Update_Application_Status
CREATE OR REPLACE FUNCTION Update_Application_Status(
    p_application_id INT,
    p_new_status VARCHAR(15),
    p_performed_by INT
)
RETURNS TEXT AS $$
DECLARE
    v_current_status VARCHAR(15);
    v_valid_status BOOLEAN;
BEGIN
    v_valid_status := p_new_status IN ('submitted', 'shortlisted', 'rejected', 'accepted');

    IF NOT v_valid_status THEN
        RETURN 'ERROR: Invalid status! Must be submitted, shortlisted, rejected, or accepted.';
    END IF;

    SELECT status INTO v_current_status
    FROM Applications
    WHERE application_id = p_application_id;

    IF NOT FOUND THEN
        RETURN 'ERROR: Application not found!';
    END IF;

    IF v_current_status IN ('accepted', 'rejected') THEN
        RETURN 'ERROR: Cannot change status of an already ' || v_current_status || ' application!';
    END IF;

    -- Set session variable so the AuditLog trigger knows who made this change
    PERFORM set_config('app.performed_by', p_performed_by::TEXT, TRUE);

    UPDATE Applications
    SET status = p_new_status
    WHERE application_id = p_application_id;

    RETURN 'SUCCESS: Status updated to ' || p_new_status || '!';

EXCEPTION
    WHEN OTHERS THEN
        RETURN 'ERROR: ' || SQLERRM;
END;
$$ LANGUAGE plpgsql;

-- TEST 1: Sara applies to Job 1 
SELECT Apply_For_Job(1, 1);

-- TEST 2: Sara applies to Job 2 
SELECT Apply_For_Job(1, 2);

-- TEST 3: Ali applies to Job 1 
SELECT Apply_For_Job(2, 1);

-- TEST 4: Ali applies to Job 3 
SELECT Apply_For_Job(2, 3);

-- TEST 5: Zara applies to Job 3 
SELECT Apply_For_Job(3, 3);

-- TEST 6: Zara applies to Job 1 
SELECT Apply_For_Job(3, 1);

-- TEST 7: Sara applies to Job 1 again 
SELECT Apply_For_Job(1, 1);

-- for the next test
SELECT application_id, student_id, job_id, status, match_score
FROM Applications
ORDER BY application_id;

-- for each submitted application
SELECT Calculate_Match_Score(7);
SELECT Calculate_Match_Score(8);
SELECT Calculate_Match_Score(9);
SELECT Calculate_Match_Score(10);

SELECT
	a.name AS student,
    jp.title AS job,
    app.match_score,
    app.rank_position,
    app.status
FROM Applications app
JOIN Students s ON app.student_id = s.student_id
JOIN Accounts a ON s.student_id = a.account_id
JOIN Job_Posts jp ON app.job_id = jp.job_id
ORDER BY jp.title, app.rank_position;

-- Sara (student_id 1): should see all 3 jobs, ranked by fit
SELECT * FROM Generate_Job_Recommendations(1);

-- Zara (student_id 3): should see nothing
SELECT * FROM Generate_Job_Recommendations(3);

-- Verifying all 04 procedures exist
SELECT routine_name
FROM information_schema.routines
WHERE routine_schema = 'public'
ORDER BY routine_name;

-- Triggers
-- Trigger 1: Auto Calculate Score After Application Insert (for successful ones only)
CREATE OR REPLACE FUNCTION trg_auto_calculate_score()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.status = 'submitted' THEN
        PERFORM Calculate_Match_Score(NEW.application_id);
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_auto_score
AFTER INSERT ON Applications
FOR EACH ROW
EXECUTE FUNCTION trg_auto_calculate_score();

-- Trigger 2: Validate Job is Active Before Application Insert
CREATE OR REPLACE FUNCTION trg_validate_job_active()
RETURNS TRIGGER AS $$
DECLARE
    v_job_status VARCHAR(10);
BEGIN
    SELECT status INTO v_job_status
    FROM Job_Posts
    WHERE job_id = NEW.job_id;

    IF v_job_status != 'active' THEN
        RAISE EXCEPTION 'Cannot apply to a job that is not active!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_job_active
BEFORE INSERT ON Applications
FOR EACH ROW
EXECUTE FUNCTION trg_validate_job_active();

-- Trigger 3: AuditLog on Status Change
CREATE OR REPLACE FUNCTION trg_audit_status_change()
RETURNS TRIGGER AS $$
DECLARE
    v_performed_by INT;
BEGIN
    IF OLD.status <> NEW.status THEN
        BEGIN
            v_performed_by := current_setting('app.performed_by')::INT;
        EXCEPTION WHEN OTHERS THEN
            v_performed_by := NULL;
        END;

        INSERT INTO AuditLog (action, entity, entity_id, performed_by, timestamp)
        VALUES (
            'STATUS_CHANGED_FROM_' || OLD.status || '_TO_' || NEW.status,
            'Applications',
            NEW.application_id,
            v_performed_by,
            NOW()
        );
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_audit_log
AFTER UPDATE ON Applications
FOR EACH ROW
EXECUTE FUNCTION trg_audit_status_change();

-- Trigger 4: Prevent Past Deadline on Job Post Insert
CREATE OR REPLACE FUNCTION trg_validate_job_deadline()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.deadline < CURRENT_DATE THEN
        RAISE EXCEPTION 'Job posting deadline cannot be in the past! Deadline entered: %', NEW.deadline;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_validate_deadline
BEFORE INSERT ON Job_Posts
FOR EACH ROW
EXECUTE FUNCTION trg_validate_job_deadline();

-- Trigger Tests
-- Test Trigger 1: Auto score
DELETE FROM Applications;

SELECT Apply_For_Job(1, 1);
SELECT Apply_For_Job(2, 1);

SELECT application_id, student_id, job_id, match_score, rank_position, status
FROM Applications;

-- Test Trigger 2: Job active validation
-- Close Job 1 
UPDATE Job_Posts SET status = 'closed' WHERE job_id = 1;

-- Try applying to the closed job 
SELECT Apply_For_Job(3, 1);

-- Reopen Job 1 for the rest of testing
UPDATE Job_Posts SET status = 'active' WHERE job_id = 1;

SELECT Apply_For_Job(1, 2);
SELECT Apply_For_Job(2, 3);
SELECT Apply_For_Job(3, 3);
SELECT Apply_For_Job(3, 1);

-- Test Trigger 3: AuditLog
-- Check current application IDs
SELECT application_id, student_id, job_id, status FROM Applications ORDER BY application_id;

-- Shortlist Sara's application for Job 1 
-- Recruiter Omar has account_id 4
SELECT Update_Application_Status(34, 'shortlisted', 4);

SELECT * FROM AuditLog;


-- Test Trigger 4: Past deadline
-- Inserting a job with a past deadline
INSERT INTO Job_Posts (company_id, title, description, min_cgpa, deadline, salary, status)
VALUES (1, 'Test Job', 'Test description', 3.0, '2020-01-01', 50000.00, 'active');

-- Views
-- View 1: Active_Jobs_View
CREATE OR REPLACE VIEW Active_Jobs_View AS
SELECT
    jp.job_id,
    jp.title,
    c.name AS company_name,
    c.location,
    jp.salary,
    jp.min_cgpa,
    jp.deadline,
    jp.posted_at,
    COUNT(jrs.skill_id) AS required_skill_count

FROM Job_Posts jp
JOIN Companies c
 	ON jp.company_id = c.company_id
LEFT JOIN Job_Required_Skills jrs
	ON jp.job_id = jrs.job_id
WHERE jp.status = 'active'
	AND jp.deadline >= CURRENT_DATE
GROUP BY jp.job_id, jp.title, c.name, c.location, jp.salary, jp.min_cgpa, jp.deadline, jp.posted_at;

SELECT * FROM Active_Jobs_View;

-- View 2: Top_Ranked_Applicants_View
CREATE OR REPLACE VIEW Top_Ranked_Applicants_View AS
SELECT
    jp.job_id,
    jp.title AS job_title,
    c.name AS company_name,
    a.name AS student_name,
    a.email AS student_email,
    s.cgpa,
    s.major,
    app.match_score,
    app.rank_position,
    app.status,
    app.apply_date,
    app.application_id
FROM Applications app
JOIN Students s ON app.student_id = s.student_id
JOIN Accounts a ON s.student_id = a.account_id
JOIN Job_Posts jp ON app.job_id = jp.job_id
JOIN Companies c ON jp.company_id = c.company_id
WHERE app.status != 'rejected'
ORDER BY jp.job_id, app.rank_position ASC NULLS LAST;

SELECT * FROM Top_Ranked_Applicants_View;

-- View 3: Eligible_Students_View
CREATE OR REPLACE VIEW Eligible_Students_View AS
SELECT DISTINCT
    s.student_id,
    jp.job_id,
    jp.title AS job_title,
    a.name AS student_name,
    s.cgpa,
    s.major,
    s.graduation_year
FROM Students s
JOIN Accounts a
    ON s.student_id = a.account_id
JOIN Job_Posts jp
    ON s.cgpa >= jp.min_cgpa
JOIN Job_Required_Skills jrs
    ON jp.job_id = jrs.job_id
JOIN Student_Skills ss
    ON ss.student_id = s.student_id
    AND ss.skill_id = jrs.skill_id
WHERE jp.status = 'active'
    AND jp.deadline >= CURRENT_DATE
ORDER BY jp.job_id, s.cgpa DESC;

SELECT * FROM Eligible_Students_View WHERE job_id = 1;

-- View 4: Application_Funnel_View
CREATE OR REPLACE VIEW Application_Funnel_View AS
SELECT
    jp.job_id,
    jp.title AS job_title,
    jp.status AS job_status,
    c.name AS company_name,
    COUNT(CASE WHEN app.status = 'submitted' THEN 1 END) AS submitted_count,
    COUNT(CASE WHEN app.status = 'shortlisted' THEN 1 END) AS shortlisted_count,
    COUNT(CASE WHEN app.status = 'rejected' THEN 1 END) AS rejected_count,
    COUNT(CASE WHEN app.status = 'accepted' THEN 1 END) AS accepted_count,
    COUNT(app.application_id) AS total_applications
FROM Job_Posts jp
JOIN Companies c ON jp.company_id = c.company_id
LEFT JOIN Applications app ON jp.job_id = app.job_id
GROUP BY jp.job_id, jp.title, jp.status, c.name
ORDER BY jp.job_id;

SELECT * FROM Application_Funnel_View;

-- Indexes
CREATE INDEX idx_accounts_email
ON Accounts(email);

CREATE INDEX idx_jobposts_status_deadline
ON Job_Posts(status, deadline);

CREATE INDEX idx_applications_jobid_score
ON Applications(job_id, match_score);

CREATE INDEX idx_skills_name
ON Skills(skill_name);

-- Verifying
SELECT indexname, tablename
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
      'idx_accounts_email',
      'idx_jobposts_status_deadline',
      'idx_applications_jobid_score',
      'idx_skills_name'
  );

  -- Final Verification
SELECT 'Tables' AS category, COUNT(*) AS count
FROM information_schema.tables
WHERE table_schema = 'public' AND table_type = 'BASE TABLE'
UNION ALL
SELECT 'Procedures', COUNT(*)
FROM information_schema.routines
WHERE routine_schema = 'public'
UNION ALL
SELECT 'Views', COUNT(*)
FROM information_schema.views
WHERE table_schema = 'public'
UNION ALL
SELECT 'My Indexes', COUNT(*)
FROM pg_indexes
WHERE schemaname = 'public'
  AND indexname IN (
      'idx_accounts_email',
      'idx_jobposts_status_deadline',
      'idx_applications_jobid_score',
      'idx_skills_name'
  );