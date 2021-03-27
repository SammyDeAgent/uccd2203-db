-- QUERY 1
SELECT Department.Dept_ID, Department.Dept_Name, COUNT(S_ID) Number_Of_Staff
FROM Staff, Department
WHERE Staff.Dept_ID = Department.Dept_ID
GROUP BY Department.Dept_ID, Department.Dept_Name
ORDER BY 1;

-- QUERY 2
BREAK ON Manager SKIP 1 ON Manager_ID SKIP 0;
COLUMN Manager  FORMAT A20;
COLUMN Employee FORMAT A20;
SELECT M.S_ID Manager_ID, M.S_FName||' '||M.S_LName Manager, S.S_ID Staff_ID, S.S_FName||' '||S.S_LName Employee
FROM Staff M, Staff S, Department
WHERE M.S_ID IN (
    SELECT HOD_ID
    FROM Staff, Department
    WHERE Staff.Dept_ID = Department.Dept_ID
    AND Staff.S_ID = Department.HOD_ID
)
AND S.Dept_ID = Department.Dept_ID
AND M.Dept_ID = Department.Dept_ID
AND M.S_ID = Department.HOD_ID
AND NOT (S.S_ID = M.S_ID)
ORDER BY 1,3;
                                                                                                                                                                                                                                                                                                                                                                                                      

-- QUERY 3
COLUMN Patient_Name FORMAT A20;
COLUMN P_PhoneNo    FORMAT A16;
SELECT P.P_ID, P.P_FName||' '||P.P_LName Patient_Name, P.P_PhoneNo, P_Address
FROM Admission adm, Patient P
WHERE P.P_ID = adm.P_ID
AND adm.Dc_Date IS NOT NULL
AND adm.Bill_Paid = 'N';

-- QUERY 4
COLUMN Med_Name     FORMAT A30;
SELECT P.P_ID, Med.Med_Name, MH.Med_DateTake, MH.Med_QtyTake
FROM Medicine Med, Medicine_Hx MH, Patient P
WHERE P.P_ID = MH.P_ID
AND Med.Med_ID = MH.Med_ID
ORDER BY 1;

-- QUERY 5
SELECT P_ID, P_PhoneNo FROM Patient WHERE P_ID = 'PA105';

UPDATE Patient
    SET P_PhoneNo = '6015 3332277'
    WHERE P_ID = 'PA105'
;

SELECT P_ID, P_PhoneNo FROM Patient WHERE P_ID = 'PA105';

ROLLBACK;

-- QUERY 6
SELECT * FROM room WHERE R_Code = 'R107';

UPDATE room
    SET R_Type = 'Presidental Suite',
        R_Capacity = 2
    WHERE R_Code = 'R107'
;

SELECT * FROM room WHERE R_CODE = 'R107';

ROLLBACK;

-- QUERY 7
BREAK ON P_ID;
SELECT P_ID, Med_ID, Med_DateTake, Med_QtyTake FROM Medicine_Hx WHERE P_ID = 'PA101';

INSERT INTO Medicine_Hx VALUES ('M109','PA101',to_date('12-FEB-21','DD-MON-RR'),3);

SELECT P_ID, Med_ID, Med_DateTake, Med_QtyTake FROM Medicine_Hx WHERE P_ID = 'PA101';
CLEAR BREAK;

ROLLBACK;

-- QUERY 8
SELECT * FROM room;

INSERT INTO room VALUES ('R108','Emergency COVID-19 Quarantine Zone',150);

SELECT * FROM room;

ROLLBACK;

-- QUERY 9
COLUMN Dept_Name FORMAT A35;
COLUMN Total_Credit_Distribution    FORMAT $999,999.00;
COLUMN Average_Funds                FORMAT $999,999.00;
SELECT Department.Dept_Name, SUM(Staff.S_Salary) Total_Credit_Distribution, AVG(Staff.S_Salary) Average_Funds, COUNT(*) Staffs
FROM Staff, Department
WHERE Staff.Dept_ID = Department.Dept_ID
GROUP BY Department.Dept_Name
ORDER BY 2 DESC;

-- QUERY 10
COLUMN Patient_Name FORMAT A20;
SELECT P_ID, P_FName||' '||P_LName Patient_Name, P_DOB, Trunc(Round((SYSDATE - to_date(P_DOB))/365.25, 5)) Age
FROM Patient
WHERE Trunc(Round((SYSDATE - to_date(P_DOB))/365.25, 5)) < 18
ORDER BY 4 DESC;


-- STORED PROCEDURE 1
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE update_hod(
    cur_Dept_ID     IN VARCHAR2,
    cur_HOD_ID      IN VARCHAR2
)
IS 
BEGIN
    UPDATE Department
        SET HOD_ID = cur_HOD_ID
        WHERE Dept_ID = cur_Dept_ID;
    UPDATE Staff
        SET Dept_ID = cur_Dept_ID
        WHERE S_ID = cur_HOD_ID;
END;
/

SELECT * FROM Department;
EXEC update_hod('D101','SA115');
SELECT * FROM Department;

ROLLBACK;

-- STORED PROCEDURE 2
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE show_expired_med(
    selected_date   IN  DATE
)
AS
BEGIN
    DBMS_OUTPUT.PUT_LINE('Med_ID    Med_Name        Med_Qty');
    DBMS_OUTPUT.PUT_LINE('========= =============== =========');
    FOR row IN (
        SELECT * FROM Medicine WHERE Med_ExpDate < selected_date
    )
    LOOP
        DBMS_OUTPUT.PUT_LINE(row.Med_ID||'      '||row.Med_Name||'             '||row.Med_Qty);
    END LOOP;
END;
/

EXEC show_expired_med(to_date('31-Aug-24','DD-MON-RR'));

-- STORED PROCEDURE 3
CREATE OR REPLACE PROCEDURE update_asgn(
    cur_p_id        IN VARCHAR2,
    cur_s_id        IN VARCHAR2
)
IS
    temp_adm_id VARCHAR2(4);
BEGIN
    SELECT Adm_ID
    INTO temp_adm_id
    FROM Admission
    WHERE P_ID = cur_p_id;

    UPDATE Assignment
        SET S_ID = cur_s_id
        WHERE Adm_ID = temp_adm_id;
END;
/

SELECT adm.P_ID, asgn.S_ID FROM Admission adm, Assignment asgn WHERE adm.Adm_ID = asgn.Adm_ID AND P_ID = 'PA102';

EXEC update_asgn('PA102','SA115');

SELECT adm.P_ID, asgn.S_ID FROM Admission adm, Assignment asgn WHERE adm.Adm_ID = asgn.Adm_ID AND P_ID = 'PA102';

ROLLBACK;

-- STORED PROCEDURE 4
CREATE OR REPLACE PROCEDURE switch_bed(
    cur_p_id_1      IN VARCHAR2,
    cur_p_id_2      IN VARCHAR2
)IS
    temp_bed_id_1   VARCHAR2(6);
    temp_bed_id_2   VARCHAR2(6);
BEGIN
    SELECT Bed_ID
    INTO temp_bed_id_1
    FROM Admission
    WHERE P_ID = cur_p_id_1;

    UPDATE Admission
        SET Bed_ID = NULL
        WHERE P_ID = cur_p_id_1;

    SELECT Bed_ID
    INTO temp_bed_id_2
    FROM Admission
    WHERE P_ID = cur_p_id_2;

    UPDATE Admission
        SET Bed_ID = NULL
        WHERE P_ID = cur_p_id_2;

    UPDATE Admission
        SET Bed_ID = temp_bed_id_2
        WHERE P_ID = cur_p_id_1;

    UPDATE Admission
        SET Bed_ID = temp_bed_id_1
        WHERE P_ID = cur_p_id_2;
    
END;
/

SELECT P_ID, Bed_ID FROM Admission WHERE P_ID = 'PA101' OR P_ID = 'PA113';

EXEC switch_bed('PA101','PA113');

SELECT P_ID, Bed_ID FROM Admission WHERE P_ID = 'PA101' OR P_ID = 'PA113';

ROLLBACK;

-- STORED PROCEDURE 5
SET SERVEROUTPUT ON;

CREATE OR REPLACE PROCEDURE staff_bday_check(
    birthday_month  IN INT
)IS
    no_bd_staff     INT;
BEGIN
    SELECT COUNT(*)
    INTO no_bd_staff
    FROM Staff
    WHERE EXTRACT(month FROM S_DOB) = birthday_month;

    DBMS_OUTPUT.PUT_LINE('Number of Birthday Individuals: '||no_bd_staff);
    DBMS_OUTPUT.PUT_LINE('Birthday Individuals:');
    DBMS_OUTPUT.PUT_LINE('S_DOB        S_ID       DEPT_ID    S_NAME');
    DBMS_OUTPUT.PUT_LINE('============ ========== ========== =======================');
    FOR row IN (
        SELECT *
        FROM Staff
        WHERE EXTRACT(month FROM S_DOB) = birthday_month
        ORDER BY EXTRACT(day FROM S_DOB)
    )LOOP
        DBMS_OUTPUT.PUT_LINE(row.S_DOB||'    '||row.S_ID||'      '||row.Dept_ID||'       '||row.S_FName||' '||row.S_LName);
    END LOOP;
END;
/

EXEC staff_bday_check(8);

-- FUNCTION 1
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION check_distrb_share(
    cur_s_id    IN VARCHAR2
)   RETURN NUMERIC
IS
    temp_dept_id    VARCHAR2(5);
    distrb_fund     NUMERIC(12,2);
    self_sal        NUMERIC(12,2);
    distrb_share    NUMERIC(12,2);
BEGIN
    SELECT Dept_ID, S_Salary
    INTO temp_dept_id, self_sal
    FROM Staff
    WHERE S_ID = cur_s_id;

    SELECT SUM(Staff.S_Salary)
    INTO distrb_fund
    FROM Staff, Department
    WHERE Staff.Dept_ID = Department.Dept_ID
    AND Department.Dept_ID = temp_dept_id;

    distrb_share := self_sal/distrb_fund*100.00;
    RETURN distrb_share;
END;
/

DECLARE
    calc_share      NUMERIC(12,2);
BEGIN
    calc_share := check_distrb_share('SA101');
    DBMS_OUTPUT.PUT_LINE('Employee Share: '||calc_share||'%');
END;
/

-- FUNCTION 2
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION calc_funding(
    cur_dept      IN VARCHAR2,
    cur_months    IN INT
)   RETURN  NUMERIC
IS
    temp_funding    NUMERIC(12,2);
    period_funds    NUMERIC(12,2);
BEGIN
    SELECT SUM(Staff.S_Salary)
    INTO temp_funding
    FROM Staff, Department
    WHERE Staff.Dept_ID = Department.Dept_ID
    AND Department.Dept_ID = cur_dept;

    period_funds := temp_funding*cur_months;
    RETURN period_funds;
END;
/

DECLARE
    calc_funds      NUMERIC(12,2);
BEGIN
    calc_funds := calc_funding('D101',8);
    DBMS_OUTPUT.PUT_LINE('Department Estimated Period Funding: $'||calc_funds);
END;
/

-- FUNCTION 3
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION calc_bed_mtn(
    period_month    IN INT
)   RETURN NUMERIC
IS
    total_bed_fund  NUMERIC(12,2);
    maintenance     NUMERIC(12,2);
BEGIN
    SELECT SUM(Bed_Fee)
    INTO total_bed_fund
    FROM Bed
    WHERE Bed_Status = 'OCCUPIED';

    maintenance := total_bed_fund*0.1*period_month;
    RETURN maintenance;
END;
/

DECLARE
    mtn_cost        NUMERIC(12,2);
BEGIN
    mtn_cost := calc_bed_mtn(7);
    DBMS_OUTPUT.PUT_LINE('Bed Maintenance Period Cost: $'||mtn_cost);
END;
/

-- FUNCTION 4
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION hospitalize_period(
    hp_p_id     IN VARCHAR2
)   RETURN INT
IS  
    vc_date_hp  DATE;
    dc_date_hp  DATE;
    hp_period   INT;
BEGIN
    SELECT Adm_Date, Dc_Date
    INTO vc_date_hp, dc_date_hp
    FROM Admission
    WHERE P_ID = hp_p_id;

    hp_period := dc_date_hp - vc_date_hp;
    RETURN hp_period;
END;
/

DECLARE
    hp_days         INT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('P_ID      Hospitalized Period (Days)');
    DBMS_OUTPUT.PUT_LINE('========= ==========================');
    FOR row IN(
        SELECT * FROM Admission WHERE Dc_Date IS NOT NULL ORDER BY 1
    )
    LOOP
    hp_days := hospitalize_period(row.P_ID);
    DBMS_OUTPUT.PUT_LINE(row.P_ID||'     '||hp_days);
    END LOOP;
END;
/

-- FUNCTION 5
SET SERVEROUTPUT ON;

CREATE OR REPLACE FUNCTION outstanding_day(
    out_p_id    IN VARCHAR2
)   RETURN INT
IS
    vc_date_out DATE;
    out_period  INT;
BEGIN
    SELECT Dc_Date
    INTO vc_date_out
    FROM Admission
    WHERE P_ID = out_p_id;

    out_period := SYSDATE - vc_date_out;
    RETURN out_period;
END;
/

DECLARE
    out_days        INT;
BEGIN
    DBMS_OUTPUT.PUT_LINE('Patient with Outstanding Bill: ');
    FOR row IN(
        SELECT Patient.P_ID, P_FName, P_LName, P_PhoneNo FROM Admission, Patient WHERE Dc_Date IS NOT NULL AND Bill_Paid = 'N' AND Admission.P_ID = Patient.P_ID
    )
    LOOP
    out_days := outstanding_day(row.P_ID);
    DBMS_OUTPUT.PUT_LINE(row.P_ID||' '||row.P_FName||' '||ROW.P_LName||CHR(9)||row.P_PhoneNo||' OUTSTANDING - '||out_days||' Days');
    END LOOP;
END;
/
