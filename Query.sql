-- UCCD2203 Assignment Script - Hospital Management System
-- SQL Contributor: Sammy, Jason, Darkin

-- Start prompt
prompt UCCD2203 - Hospital Database SQL Script Execution Starting...;

-- Operational Parameters and Settings
SET FEEDBACK 1
SET NUMWIDTH 10
SET LINESIZE 1000
SET TRIMSPOOL ON
SET TAB ON
SET PAGESIZE 100
SET ECHO OFF 

-- Table Reset and Validation
DROP TABLE Department   CASCADE CONSTRAINT;
DROP TABLE Staff        CASCADE CONSTRAINT;
DROP TABLE Patient      CASCADE CONSTRAINT;
DROP TABLE Patient_Dx   CASCADE CONSTRAINT;
DROP TABLE Room         CASCADE CONSTRAINT;
DROP TABLE Bed          CASCADE CONSTRAINT;
DROP TABLE Medicine     CASCADE CONSTRAINT;
DROP Table Medicine_Hx  CASCADE CONSTRAINT;
DROP TABLE Treatment    CASCADE CONSTRAINT;
DROP TABLE Treatment_Hx CASCADE CONSTRAINT;
DROP TABLE Admission    CASCADE CONSTRAINT;
DROP TABLE Assignment   CASCADE CONSTRAINT;

-- Table Creation
CREATE TABLE Department(
    Dept_ID         VARCHAR2(4),
    Dept_Name       VARCHAR2(30)    CONSTRAINT dep_dept_name_nn NOT NULL,
    HOD_ID          VARCHAR2(5),
    CONSTRAINT  dep_dept_id_pk      PRIMARY KEY (Dept_ID)
);

CREATE TABLE Staff(
    S_ID            VARCHAR2(5),
    S_FName         VARCHAR2(20),
    S_LName         VARCHAR2(20)    CONSTRAINT s_lname_nn   NOT NULL,
    S_SEX           CHAR            CONSTRAINT s_sex_nn     NOT NULL,
    S_DOB           DATE            CONSTRAINT s_dob_nn     NOT NULL,
    S_PhoneNo       VARCHAR2(17)    CONSTRAINT s_phone_nn   NOT NULL,
    S_Email         VARCHAR2(30)    CONSTRAINT s_mail_nn    NOT NULL,
    S_Address       VARCHAR2(65)    CONSTRAINT s_addr_nn    NOT NULL,
    S_DateHired     DATE            CONSTRAINT s_hired_nn   NOT NULL,
    S_DateLeave     DATE,
    S_JobTitle      VARCHAR2(25)    CONSTRAINT s_title_nn   NOT NULL,
    S_Salary        NUMERIC(12,2)   CONSTRAINT s_sal_nn     NOT NULL,  
    Dept_ID         VARCHAR2(4)     CONSTRAINT s_dept_nn    NOT NULL,
    S_ZipCode       NUMBER(5)       CONSTRAINT s_zip_nn     NOT NULL,
    S_City          VARCHAR2(25)    CONSTRAINT s_city_nn    NOT NULL,
    S_State         VARCHAR2(25)    CONSTRAINT s_state_nn   NOT NULL,
    CONSTRAINT  s_id_pk         PRIMARY KEY (S_ID),
    CONSTRAINT  s_dept_id_fk    FOREIGN KEY (Dept_ID)   REFERENCES Department(Dept_ID),
    CONSTRAINT  s_sex_symbol_check       CHECK (S_SEX = 'F' OR S_SEX = 'M'),
    CONSTRAINT  check_hired_leave_date   CHECK (S_DateHired < S_DateLeave),
    CONSTRAINT  s_salary_nonegative      CHECK (S_Salary >= 0)
);

CREATE TABLE Patient(
    P_ID            VARCHAR2(5),
    P_FName         VARCHAR2(20),
    P_LName         VARCHAR2(20)    CONSTRAINT p_lname_nn   NOT NULL,
    P_SEX           CHAR            CONSTRAINT p_sex_nn     NOT NULL,
    P_DOB           DATE            CONSTRAINT p_dob_nn     NOT NULL,
    P_PhoneNo       VARCHAR2(17)    CONSTRAINT p_phone_nn   NOT NULL,
    P_Address       VARCHAR2(65)    CONSTRAINT p_addr_nn    NOT NULL,
    P_ZipCode       NUMBER(5)       CONSTRAINT p_zip_nn     NOT NULL,
    P_City          VARCHAR2(25)    CONSTRAINT p_city_nn    NOT NULL,
    P_State         VARCHAR2(25)    CONSTRAINT p_state_nn   NOT NULL,
    CONSTRAINT  p_id_pk         PRIMARY KEY (P_ID),
    CONSTRAINT  p_sex_symbol_check      CHECK (P_SEX = 'F' OR P_SEX = 'M')
);

CREATE TABLE Patient_Dx(
    P_ID            VARCHAR2(5),
    Dx_Date         DATE,
    Dx_Desc         VARCHAR2(40)    CONSTRAINT dx_desc_nn   NOT NULL,
    CONSTRAINT  dx_p_date_ck    PRIMARY KEY (P_ID, Dx_Date),
    CONSTRAINT  dx_p_id_fk      FOREIGN Key (P_ID)      REFERENCES Patient(P_ID)
);

CREATE TABLE Room(
    R_Code          VARCHAR2(4),
    R_Type          VARCHAR2(35)    CONSTRAINT room_type_nn NOT NULL,
    R_Capacity      INT             CONSTRAINT room_cap_nn  NOT NULL,
    CONSTRAINT  r_code_pk       PRIMARY KEY (R_Code),
    CONSTRAINT  r_cap_nonegative        CHECK (R_Capacity >= 0)
);

CREATE TABLE Bed(
    Bed_ID          VARCHAR2(6),
    R_Code          VARCHAR2(4),
    Bed_Type        VARCHAR2(15)    CONSTRAINT bed_type_nn  NOT NULL,
    Bed_Fee         NUMERIC(12,2)   CONSTRAINT bed_fee_nn   NOT NULL,
    Bed_Status      VARCHAR2(8)     CONSTRAINT bed_stats_nn NOT NULL,
    CONSTRAINT  bed_id_pk       PRIMARY KEY (Bed_ID),
    CONSTRAINT  r_code_fk       FOREIGN KEY (R_Code)    REFERENCES Room(R_Code),
    CONSTRAINT  bed_fee_nonegative      CHECK (Bed_Fee >= 0),
    CONSTRAINT  bed_stats_symbol_check  CHECK (Bed_Status = 'FREE' OR Bed_Status = 'OCCUPIED')
);

CREATE TABLE Treatment(
    Trt_ID          VARCHAR2(4),
    Trt_Name        VARCHAR2(25)    CONSTRAINT trt_name_nn  NOT NULL,
    Trt_Desc        VARCHAR2(95)    CONSTRAINT trt_desc_nn  NOT NULL,
    Trt_Price       NUMERIC(12,2)   CONSTRAINT trt_price_nn NOT NULL,
    CONSTRAINT  trt_id_pk       PRIMARY KEY (Trt_ID),
    CONSTRAINT  trt_price_nonegative    CHECK (Trt_Price >= 0)
);

CREATE TABLE Treatment_Hx(
    Trt_ID          VARCHAR2(4),
    Trt_DateTake    DATE            CONSTRAINT trt_date_nn  NOT NULL,
    P_ID            VARCHAR2(5),
    S_ID            VARCHAR2(5),
    CONSTRAINT  th_trt_p_id_ck  PRIMARY KEY (Trt_ID, P_ID),
    CONSTRAINT  th_trt_id_fk    FOREIGN KEY (Trt_ID)    REFERENCES Treatment(Trt_ID),
    CONSTRAINT  th_p_id_fk      FOREIGN KEY (P_ID)      REFERENCES Patient(P_ID),
    CONSTRAINT  th_s_id_fk      FOREIGN KEY (S_ID)      REFERENCES Staff(S_ID)
);

CREATE TABLE Medicine(
    Med_ID          VARCHAR2(4),
    Med_Name        VARCHAR2(30)    CONSTRAINT med_name_nn  NOT NULL,
    Med_Desc        VARCHAR2(50)    CONSTRAINT med_desc_nn  NOT NULL,
    Med_ExpDate     DATE            CONSTRAINT med_exp_nn   NOT NULL,
    Med_Price       NUMERIC(12,2)   CONSTRAINT med_price_nn NOT NULL,
    Med_Qty         INT             CONSTRAINT med_qty_nn   NOT NULL,
    CONSTRAINT  med_id_pk       PRIMARY KEY (Med_ID),
    CONSTRAINT  med_price_nonegative    CHECK (Med_Price >= 0),
    CONSTRAINT  check_qty_nonegative    CHECK (Med_Qty >= 0)
);

CREATE TABLE Medicine_Hx(
    Med_ID          VARCHAR2(4),
    P_ID            VARCHAR2(5),
    Med_DateTake    DATE            CONSTRAINT hx_take_nn   NOT NULL,
    Med_QtyTake     INT             CONSTRAINT hx_qty_nn    NOT NULL,
    CONSTRAINT  hx_med_p_id_ck  PRIMARY KEY (Med_ID, P_ID),
    CONSTRAINT  hx_med_id_fk    FOREIGN KEY (Med_ID)    REFERENCES Medicine(Med_ID),
    CONSTRAINT  hx_p_id_fk      FOREIGN KEY (P_ID)      REFERENCES Patient(P_ID),
    CONSTRAINT  check_hx_qty_nonegative CHECK (Med_QtyTake >= 0)
);

CREATE TABLE Admission(
    Adm_ID          VARCHAR2(4),
    Adm_Date        DATE            CONSTRAINT adm_date_nn NOT NULL,
    Dc_Date         DATE,
    P_ID            VARCHAR2(5),
    Bed_ID          VARCHAR2(6),
    Bill_Paid       CHAR            CONSTRAINT bill_paid_nn NOT NULL,
    CONSTRAINT  adm_id_pk       PRIMARY KEY (Adm_ID),
    CONSTRAINT  adm_p_id_fk     FOREIGN KEY (P_ID)      REFERENCES Patient(P_ID),
    CONSTRAINT  adm_bed_id_fk   FOREIGN KEY (Bed_ID)    REFERENCES Bed(Bed_ID),
    CONSTRAINT  check_adm_dc_date       CHECK (Adm_Date < Dc_Date),
    CONSTRAINT  check_binary_bill_paid  CHECK (Bill_Paid = 'Y' OR Bill_Paid = 'N')
);

CREATE TABLE Assignment(
    Adm_ID          VARCHAR2(4),
    S_ID            VARCHAR2(5),
    CONSTRAINT  adm_s_asgn_ck   PRIMARY KEY (Adm_ID, S_ID),
    CONSTRAINT  asgn_adm_id_fk  FOREIGN KEY (Adm_ID)    REFERENCES Admission(Adm_ID),
    CONSTRAINT  asgn_s_id_fk    FOREIGN KEY (S_ID)      REFERENCES Staff(S_ID)
);

-- Data Alteration for Circular Problem
ALTER TABLE Department ADD CONSTRAINT hod_id_fk FOREIGN KEY (HOD_ID) REFERENCES Staff(S_ID);

-- Data Insertion -> Department TABLE
INSERT INTO Department VALUES('D101','Outpatient Department'    ,NULL);
INSERT INTO Department VALUES('D102','Inpatient Service'        ,NULL);
INSERT INTO Department VALUES('D103','Medical Department'       ,NULL);
INSERT INTO Department VALUES('D104','Nursing Department'       ,NULL);
INSERT INTO Department VALUES('D105','Pharmarcy Department'     ,NULL);
INSERT INTO Department VALUES('D106','Radiology Department'     ,NULL);
INSERT INTO Department VALUES('D107','Administration Department',NULL);

-- Data Insertion -> Staff TABLE
INSERT INTO Staff VALUES('SA101','Heaven'       ,'Maudie'       ,'M'    ,to_date('12-Aug-80','DD-MON-RR'),'6019 5556464', 'Maudie@outlook.com'          ,'2571 1 Jln Satok Kuching'                     ,to_date('10-Jan-15','DD-MON-RR'),NULL                              ,'Medical Records Clerk'        ,3000           ,'D101','93400' ,'Kuching'      ,'Sarawak'              );
INSERT INTO Staff VALUES('SA102','Kat'          ,'Alexis'       ,'F'    ,to_date('01-Aug-59','DD-MON-RR'),'6018 5556674', 'alexis@mac.com'              ,'2 21 Jln Dato Haji Eusoff'                    ,to_date('28-Dec-14','DD-MON-RR'),to_date('10-Mar-21','DD-MON-RR')  ,'Surgeon'                      ,10000          ,'D103','50400' ,'Kuala Lumpur' ,'Wilayah Persekutuan');
INSERT INTO Staff VALUES('SA103','Edweena'      ,'Roland'       ,'F'    ,to_date('05-Apr-58','DD-MON-RR'),'6012 5554994', 'edweenaroland@yahoo.ca'      ,'Jalan Ss 4D/10, Kelana Jaya'                  ,to_date('30-Aug-14','DD-MON-RR'),NULL                              ,'Pharmacist'                   ,4000           ,'D105','47301' ,'Petaling Jaya','Selangor');
INSERT INTO Staff VALUES('SA104','Shauna'       ,'Savannah'     ,'F'    ,to_date('10-Jan-71','DD-MON-RR'),'6017 5555617', 'shauna@gmail.com'            ,'TB , Taman Megah Jaya, 3.5KM JLN Apas'        ,to_date('22-Nov-15','DD-MON-RR'),NULL                              ,'Cheif Executive Officer'      ,12000          ,'D107','10799' ,'Tawau'        ,'Sabah');
INSERT INTO Staff VALUES('SA105','Whitaker'     ,'Luke'         ,'M'    ,to_date('11-Jul-69','DD-MON-RR'),'6014 5553334', 'luke_whitaker@yahoo.ca'      ,'Jalan Maarof, Bangsar'                        ,to_date('30-Sep-14','DD-MON-RR'),to_date('24-Mar-21','DD-MON-RR')  ,'Medical Admissions Clerk'     ,3500           ,'D102','59000' ,'Kuala Lumpur' ,'Wilayah Persekutuan');
INSERT INTO Staff VALUES('SA106','Yorick'       ,'Raegan'       ,'M'    ,to_date('14-Sep-79','DD-MON-RR'),'6015 5554794', 'yoorickraegan@gmail.com'     ,'110C-1 Jalan Kampar'                          ,to_date('19-Oct-14','DD-MON-RR'),NULL                              ,'Medical Admissions Clerk'     ,3500           ,'D101','30250' ,'Ipoh'         ,'Perak');
INSERT INTO Staff VALUES('SA107','Kirby'        ,'Kourtney'     ,'M'    ,to_date('17-Nov-89','DD-MON-RR'),'6019 5556701', 'kirby@yahoo.ca'              ,'A 3 Jln Kota Raja Taman Sri Mewah'            ,to_date('14-Jun-15','DD-MON-RR'),NULL                              ,'Medical Records Clerk'        ,3000           ,'D102','41000' ,'Klang'        ,'Selangor');
INSERT INTO Staff VALUES('SA108','Gord'         ,'Marylu'       ,'M'    ,to_date('19-Dec-92','DD-MON-RR'),'6013 5552734', 'marylugord@gmail.com'        ,'A 139 Jln Bunus'                              ,to_date('12-Aug-19','DD-MON-RR'),NULL                              ,'Radiologic Technician'        ,5000           ,'D106','50100' ,'Kuala Lumpur' ,'Wilayah Persekutuan');
INSERT INTO Staff VALUES('SA109','Sherley'      ,'Lexia'        ,'M'    ,to_date('04-Jul-95','DD-MON-RR'),'6014 5552483', 'lexisly@yahoo.ca'            ,'Blok D Pasar Awam Taman Dahlia'               ,to_date('23-Jul-19','DD-MON-RR'),NULL                              ,'Medical Admissions Clerk'     ,2500           ,'D102','81200' ,'Johor Bahru'  ,'Johor');
INSERT INTO Staff VALUES('SA110','Jacki'        ,'Sheryll'      ,'M'    ,to_date('22-Dec-78','DD-MON-RR'),'6012 5557312', 'jacksl@outlook.com'          ,'187 Jalan Simbang Taman Perling Tampoi'       ,to_date('11-Nov-14','DD-MON-RR'),NULL                              ,'Admin Clerk'                  ,3200           ,'D107','81200' ,'Johor Bahru'  ,'Johor');
INSERT INTO Staff VALUES('SA111','Letty'        ,'Pacey'        ,'F'    ,to_date('28-Nov-67','DD-MON-RR'),'6016 5551223', 'lettypacey@outlook.com'      ,'Seksyen 27, Hicom Town Centre'                ,to_date('04-Jun-14','DD-MON-RR'),to_date('23-Jan-21','DD-MON-RR')  ,'Surgeon'                      ,10000          ,'D103','40400' ,'Shah Alam'    ,'Selangor');
INSERT INTO Staff VALUES('SA112','Kym'          ,'America'      ,'F'    ,to_date('22-Mar-89','DD-MON-RR'),'6015 5557056', 'americakym@hotmail.com'      ,'18 Lbh Pasar Georgetown'                      ,to_date('20-Jul-19','DD-MON-RR'),NULL                              ,'Registered Nurse'             ,4300           ,'D104','10200' ,'Georgetown'   ,'Penang');
INSERT INTO Staff VALUES('SA113','Lorne'        ,'Amery'        ,'M'    ,to_date('03-Aug-86','DD-MON-RR'),'6011 5558723', 'lorneamery@gmail.com'        ,'12 Jln 13/48A Off Jln Sentul'                 ,to_date('27-Sep-18','DD-MON-RR'),NULL                              ,'Admin Clerk'                  ,3200           ,'D107','51100' ,'Kuala Lumpur' ,'Wilayah Persekutuan');
INSERT INTO Staff VALUES('SA114','Sage'         ,'Marcia'       ,'F'    ,to_date('24-Jun-79','DD-MON-RR'),'6014 5557190', 'sagemarcia@yahoo.ca'         ,'No. 1 3Rd Floor Jln 2/64A'                    ,to_date('05-Apr-19','DD-MON-RR'),to_date('17-Jan-21','DD-MON-RR')  ,'Pharmacist'                   ,5800           ,'D105','50350' ,'Kuala Lumpur' ,'Wilayah Persekutuan');
INSERT INTO Staff VALUES('SA115','Stu'          ,'Seraphina'    ,'F'    ,to_date('18-Nov-90','DD-MON-RR'),'6012 5556004', 'seraphina@icloud.com'        ,'16 Lbh Turi Kaw 5 Taman Chi Liung'            ,to_date('01-Feb-18','DD-MON-RR'),NULL                              ,'Pharmacist'                   ,5800           ,'D105','41200' ,'Klang'        ,'Selangor');
INSERT INTO Staff VALUES('SA116','Taylor'       ,'Colby'        ,'F'    ,to_date('13-Aug-83','DD-MON-RR'),'6014 5556324', 'colby_taylor@gmail.com'      ,'69 Jln Molek 3/10 Taman Molek'                ,to_date('08-Jan-19','DD-MON-RR'),NULL                              ,'Surgeon'                      ,10000          ,'D103','81100' ,'Johor Bahru'  ,'Johor');
INSERT INTO Staff VALUES('SA117','Erika'        ,'Moreen'       ,'F'    ,to_date('18-May-76','DD-MON-RR'),'6014 5556324', 'erikamoreen@mac.com'         ,'50 Jalan Tempinis 4 Taman Wira Batu 6'        ,to_date('17-Sep-16','DD-MON-RR'),to_date('21-Mar-21','DD-MON-RR')  ,'Registered Nurse'             ,4300           ,'D104','41050' ,'Klang'        ,'Selangor');
INSERT INTO Staff VALUES('SA118','Ike'          ,'Kalyn'        ,'M'    ,to_date('26-Apr-87','DD-MON-RR'),'6013 5556465', 'kalynIKE@gmail.com'          ,'Ag2901 Jalan Padang Sebang Abatu'             ,to_date('29-Dec-17','DD-MON-RR'),NULL                              ,'Registered Nurse'             ,4300           ,'D104','70000' ,'Seremban'     ,'Negeri Sembilan');
INSERT INTO Staff VALUES('SA119','Rollo'        ,'McKenzie'     ,'M'    ,to_date('30-Aug-66','DD-MON-RR'),'6016 5553349', 'Mckenzierollo@hotmail.com'   ,'30A 1St Floor Lorong Datuk Sulaiman 1'        ,to_date('21-Jun-15','DD-MON-RR'),to_date('10-Dec-20','DD-MON-RR')  ,'Radiologic Technician'        ,5000           ,'D106','60000' ,'Kuala Lumpur' ,'Wilayah Persekutuan');
INSERT INTO Staff VALUES('SA120','Honor'        ,'Terri'        ,'M'    ,to_date('07-Jun-94','DD-MON-RR'),'6010 5553023', 'terriHonor@outlook.com'      ,'105 Taman Muslim Bunga Jalan Tasek'           ,to_date('15-Sep-19','DD-MON-RR'),NULL                              ,'Registered Nurse'             ,4300           ,'D104','31400' ,'Ipoh'         ,'Perak');

-- Data Insertion -> Patient TABLE
INSERT INTO Patient VALUES('PA101','Wai Hin'        ,'Lee'          ,'M'    ,to_date('14-Jun-00','DD-MON-RR'),'6014 3899912', 'No. 5 Jln Ba/1 Kaw Perusahaan Bukit Angkat'              ,'43000','Kajang'           ,'Selangor');
INSERT INTO Patient VALUES('PA102','Moss'           ,'Drake'        ,'M'    ,to_date('04-Aug-78','DD-MON-RR'),'6013 5669091', 'No. 90 Ground Floor Jln Dato Bandar Tunggal'             ,'70000','Seremban'         ,'Negeri Sembilan');
INSERT INTO Patient VALUES('PA103','Vanessa'        ,'Sharron'      ,'F'    ,to_date('15-Mar-99','DD-MON-RR'),'6018 5670485', 'Plo 31 11 Jalan Firma 2/1 Kawasan Perindustrian Tebrau'  ,'81100','Johor Bahru'      ,'Johor');
INSERT INTO Patient VALUES('PA104','Carol'          ,'Lorainne'     ,'F'    ,to_date('16-Jan-70','DD-MON-RR'),'6012 5769880', 'No. 10 Jln Landak Off Jln Pasar'                         ,'55100','Kuala Lumpur'     ,'Wilayah Persekutuan');
INSERT INTO Patient VALUES('PA105','Stanley'        ,'Allen'        ,'M'    ,to_date('18-Jun-50','DD-MON-RR'),'6017 2345879', '15-2 Jalan PJU 5/18 Dataran Sunway Kota Damansara'       ,'47810','Petaling Jaya'    ,'Selangor');
INSERT INTO Patient VALUES('PA106','Roxie'          ,'Angelica'     ,'F'    ,to_date('07-Mar-77','DD-MON-RR'),'6013 7893432', '42 1St Floor Jalan Kemuja Off Jalan Bangsar'             ,'50000','Kuala Lumpur'     ,'Wilayah Persekutuan');
INSERT INTO Patient VALUES('PA107','Charlic'        ,'Jim'          ,'M'    ,to_date('23-Oct-88','DD-MON-RR'),'6016 3218790', '12 PSN Buntong Jaya 17 Taman Bina Ria'                   ,'30100','Ipoh'             ,'Perak');
INSERT INTO Patient VALUES('PA108','Sandie'         ,'Isebella'     ,'F'    ,to_date('22-Mar-21','DD-MON-RR'),'6017 1235679', 'Lot 5, Kampung Mengabang Telipot'                        ,'10307','Kuala Terengganu' ,'Terengganu');
INSERT INTO Patient VALUES('PA109','Frank'          ,'Richmal'      ,'M'    ,to_date('28-May-87','DD-MON-RR'),'6014 9842340', 'PJU 9, Bandar Sri Damansara'                             ,'52200','Kuala Lumpur'     ,'Wilayah Persekutuan');
INSERT INTO Patient VALUES('PA110','Eddy'           ,'Kaylie'       ,'M'    ,to_date('24-Feb-21','DD-MON-RR'),'6016 4360890', '1 2 Jln Usj 9/5N Taman Seafield Jaya'                    ,'47620','Petaling Jaya'    ,'Selangor');
INSERT INTO Patient VALUES('PA111','Keaton'         ,'Destiny'      ,'M'    ,to_date('24-Oct-74','DD-MON-RR'),'6017 9875743', '36, Jalan Haji Saman'                                    ,'88000','Kota Kinabalu'    ,'Sabah');
INSERT INTO Patient VALUES('PA112','John'           ,'Wick'         ,'M'    ,to_date('17-Mar-87','DD-MON-RR'),'6014 2899912', 'Majlis Daerah Bandar Baru 24 Jln Raya'                   ,'9800','Serdang'           ,'Kedah');
INSERT INTO Patient VALUES('PA113','Dusty'          ,'Allie'        ,'M'    ,to_date('24-Jun-62','DD-MON-RR'),'6011 9453899', 'Jalan Seri Setali 1, Off Jalan Air Putih'                ,'25300','Kuantan'          ,'Pahang');
INSERT INTO Patient VALUES('PA114','Jie Nan'        ,'Tan'          ,'M'    ,to_date('13-Aug-90','DD-MON-RR'),'6014 4899913', 'Jalan FZ 2-P5 Port Free Zone/KS 12'                      ,'42920','Klang'            ,'Selangor');
INSERT INTO Patient VALUES('PA115','Sammy'          ,'Yee'          ,'M'    ,to_date('17-Mar-97','DD-MON-RR'),'6014 2899914', '4 Pga Tunku Bukit Tunku'                                 ,'50480','Kuala Lumpur'     ,'Wilayah Persekutuan');
INSERT INTO Patient VALUES('PA116','John'           ,'Cena'         ,'M'    ,to_date('17-Jun-62','DD-MON-RR'),'6013 4899915', 'Jalan 16/11, Off Jalan Damansara'                        ,'46350','Petaling Jaya'    ,'Selangor');
INSERT INTO Patient VALUES('PA117','Ibbie'          ,'Maree'        ,'F'    ,to_date('26-Feb-21','DD-MON-RR'),'6015 2726655', '42 Jln Siput Akek Taman Billiun'                         ,'56000','Kuala Lumpur'     ,'Wilayah Persekutuan');
INSERT INTO Patient VALUES('PA118','Gaynor'         ,'Kent'         ,'M'    ,to_date('09-Sep-93','DD-MON-RR'),'6016 7271234', '268 G Jln Sungai Padungan Kuching'                       ,'93100','Kuching'          ,'Sarawak');
INSERT INTO Patient VALUES('PA119','Alysa'          ,'Betty'        ,'F'    ,to_date('12-Dec-10','DD-MON-RR'),'6019 0892341', 'No. 9R Jalan Bukit Meldrum'                              ,'80300','Johor Bahru'      ,'Johor');
INSERT INTO Patient VALUES('PA120','Neil'           ,'Cecily'       ,'M'    ,to_date('15-Mar-21','DD-MON-RR'),'6011 3405678', '36 Jln Yong Shook Lin Seksyen 52'                        ,'46200','Petaling Jaya'    ,'Selangor');

-- Data Insertion -> Patient_Dx TABLE
INSERT INTO Patient_Dx VALUES('PA101',to_date('07-Jan-21','DD-MON-RR'),'Brain Tumours');
INSERT INTO Patient_Dx VALUES('PA102',to_date('15-Jan-21','DD-MON-RR'),'Kidney Cancer');
INSERT INTO Patient_Dx VALUES('PA103',to_date('11-Feb-21','DD-MON-RR'),'Liver Cancer');
INSERT INTO Patient_Dx VALUES('PA104',to_date('17-Mar-21','DD-MON-RR'),'Oesophageal Cancer');
INSERT INTO Patient_Dx VALUES('PA105',to_date('23-Mar-21','DD-MON-RR'),'Coma');
INSERT INTO Patient_Dx VALUES('PA106',to_date('26-Jan-21','DD-MON-RR'),'Congenital Heart Disease');
INSERT INTO Patient_Dx VALUES('PA107',to_date('13-Feb-21','DD-MON-RR'),'Bowel Cancer');
INSERT INTO Patient_Dx VALUES('PA108',to_date('22-Mar-21','DD-MON-RR'),'New Born');
INSERT INTO Patient_Dx VALUES('PA109',to_date('17-Feb-21','DD-MON-RR'),'Indigestion');
INSERT INTO Patient_Dx VALUES('PA110',to_date('24-Feb-21','DD-MON-RR'),'New Born');
INSERT INTO Patient_Dx VALUES('PA111',to_date('18-Mar-21','DD-MON-RR'),'Urinary Tract Infection');
INSERT INTO Patient_Dx VALUES('PA112',to_date('09-Mar-21','DD-MON-RR'),'Diarrhoea');
INSERT INTO Patient_Dx VALUES('PA113',to_date('11-Mar-21','DD-MON-RR'),'Malnutrition');
INSERT INTO Patient_Dx VALUES('PA114',to_date('17-Mar-21','DD-MON-RR'),'Thyroid Cancer');
INSERT INTO Patient_Dx VALUES('PA115',to_date('28-Jan-21','DD-MON-RR'),'Constipation');
INSERT INTO Patient_Dx VALUES('PA116',to_date('08-Feb-21','DD-MON-RR'),'Stroke');
INSERT INTO Patient_Dx VALUES('PA117',to_date('26-Feb-21','DD-MON-RR'),'New Born');
INSERT INTO Patient_Dx VALUES('PA118',to_date('28-Jan-21','DD-MON-RR'),'Stomach Cancer');
INSERT INTO Patient_Dx VALUES('PA119',to_date('25-Jan-21','DD-MON-RR'),'Womb Cancer');
INSERT INTO Patient_Dx VALUES('PA120',to_date('15-Mar-21','DD-MON-RR'),'New Born');

-- Data Insertion -> Room TABLE
INSERT INTO Room VALUES('R101','2-BEDDED'                       ,2);
INSERT INTO Room VALUES('R102','4-BEDDED'                       ,4);
INSERT INTO Room VALUES('R103','COMMON WARD'                    ,6);
INSERT INTO Room VALUES('R104','INTENSIVE CARE UNIT'            ,4);
INSERT INTO Room VALUES('R105','NEONETAL INTENSIVE CARE UNIT'   ,15);
INSERT INTO Room VALUES('R106','DELIVARY SUITE'                 ,1);
INSERT INTO Room VALUES('R107','Private'                        ,1);

-- Data Insertion -> Bed TABLE
INSERT INTO Bed VALUES('BED101','R102','GATCH'          ,80.00      ,'OCCUPIED');
INSERT INTO Bed VALUES('BED102','R102','ELECTRIC'       ,180.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED103','R102','ELECTRIC'       ,180.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED104','R104','ELECTRIC'       ,350.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED105','R103','GATCH'          ,60.00      ,'OCCUPIED');
INSERT INTO Bed VALUES('BED106','R104','ELECTRIC'       ,350.00     ,'FREE');
INSERT INTO Bed VALUES('BED107','R101','ELECTRIC'       ,200.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED108','R105','CRIBS'          ,120.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED109','R103','GATCH'          ,60.00      ,'FREE');
INSERT INTO Bed VALUES('BED110','R105','CRIBS'          ,120.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED111','R103','ELECTRIC'       ,160.00     ,'FREE');
INSERT INTO Bed VALUES('BED112','R103','GATCH'          ,60.00      ,'OCCUPIED');
INSERT INTO Bed VALUES('BED113','R103','GATCH'          ,60.00      ,'OCCUPIED');
INSERT INTO Bed VALUES('BED114','R104','ELECTRIC'       ,350.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED115','R103','GATCH'          ,60.00      ,'OCCUPIED');
INSERT INTO Bed VALUES('BED116','R101','ELECTRIC'       ,200.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED117','R105','CRIBS'          ,120.00     ,'FREE');
INSERT INTO Bed VALUES('BED118','R107','ELECTRIC'       ,250.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED119','R104','ELECTRIC'       ,350.00     ,'OCCUPIED');
INSERT INTO Bed VALUES('BED120','R105','CRIBS'          ,120.00     ,'OCCUPIED');

-- Data Insertion -> Treatment TABLE
INSERT INTO Treatment VALUES('T101','Surgery'       ,'Medical Operative Manual and Instrumental Techniques Treat Pathological Condition',10000);
INSERT INTO Treatment VALUES('T102','Radiotherapy'  ,'Radiation Treatment'                                                              ,4000);
INSERT INTO Treatment VALUES('T103','Chemotherapy'  ,'Drug Treatment'                                                                   ,3000);
INSERT INTO Treatment VALUES('T104','Physiotherapy' ,'Including Physical Rehabilitation, Injury Prevention and Health and Fitness'      ,10000);
INSERT INTO Treatment VALUES('T105','Baby Delivery' ,'Including Natural/Caesarean Delivery'                                             ,10000);
INSERT INTO Treatment VALUES('T106','Diagnostics'   ,'Including MRI/CT Scans'                                                           ,1500);

-- Data Insertion -> Treatment_Hx TABLE
INSERT INTO Treatment_Hx VALUES('T102',to_date('10-Jan-21','DD-MON-RR'),'PA101','SA111');
INSERT INTO Treatment_Hx VALUES('T104',to_date('19-Mar-21','DD-MON-RR'),'PA101','SA118');
INSERT INTO Treatment_Hx VALUES('T101',to_date('18-Jan-21','DD-MON-RR'),'PA102','SA116');
INSERT INTO Treatment_Hx VALUES('T101',to_date('14-Feb-21','DD-MON-RR'),'PA103','SA102');
INSERT INTO Treatment_Hx VALUES('T103',to_date('19-Mar-21','DD-MON-RR'),'PA104','SA116');
INSERT INTO Treatment_Hx VALUES('T106',to_date('25-Mar-21','DD-MON-RR'),'PA105','SA111');
INSERT INTO Treatment_Hx VALUES('T103',to_date('29-Jan-21','DD-MON-RR'),'PA106','SA116');
INSERT INTO Treatment_Hx VALUES('T104',to_date('25-Feb-21','DD-MON-RR'),'PA106','SA112');
INSERT INTO Treatment_Hx VALUES('T106',to_date('16-Feb-21','DD-MON-RR'),'PA107','SA102');
INSERT INTO Treatment_Hx VALUES('T105',to_date('22-Mar-21','DD-MON-RR'),'PA108','SA111');
INSERT INTO Treatment_Hx VALUES('T106',to_date('19-Feb-21','DD-MON-RR'),'PA109','SA120');
INSERT INTO Treatment_Hx VALUES('T105',to_date('24-Feb-21','DD-MON-RR'),'PA110','SA116');
INSERT INTO Treatment_Hx VALUES('T103',to_date('19-Mar-21','DD-MON-RR'),'PA111','SA111');
INSERT INTO Treatment_Hx VALUES('T106',to_date('12-Mar-21','DD-MON-RR'),'PA112','SA117');
INSERT INTO Treatment_Hx VALUES('T106',to_date('13-Mar-21','DD-MON-RR'),'PA113','SA112');
INSERT INTO Treatment_Hx VALUES('T102',to_date('18-Mar-21','DD-MON-RR'),'PA114','SA102');
INSERT INTO Treatment_Hx VALUES('T106',to_date('28-Jan-21','DD-MON-RR'),'PA115','SA118');
INSERT INTO Treatment_Hx VALUES('T106',to_date('11-Feb-21','DD-MON-RR'),'PA116','SA116');
INSERT INTO Treatment_Hx VALUES('T105',to_date('26-Feb-21','DD-MON-RR'),'PA117','SA102');
INSERT INTO Treatment_Hx VALUES('T101',to_date('05-Feb-21','DD-MON-RR'),'PA118','SA111');
INSERT INTO Treatment_Hx VALUES('T101',to_date('05-Feb-21','DD-MON-RR'),'PA119','SA102');
INSERT INTO Treatment_Hx VALUES('T105',to_date('15-Mar-21','DD-MON-RR'),'PA120','SA116');

-- Data Insertion -> Medicine TABLE
INSERT INTO Medicine VALUES('M101','PCV'                ,'Drug Combination for Brain Tumours'               ,to_date('01-Jan-24','DD-MON-RR'),250       ,100);
INSERT INTO Medicine VALUES('M102','Sunitinib Malate'   ,'For Renal Cell Carcinoma (Kidney Cancer)'         ,to_date('10-Nov-27','DD-MON-RR'),300       ,300);
INSERT INTO Medicine VALUES('M103','Opdivo'             ,'For Liver Cancer'                                 ,to_date('23-Aug-25','DD-MON-RR'),600       ,200);
INSERT INTO Medicine VALUES('M104','ECF'                ,'For Oesophagael Cancer'                           ,to_date('12-Apr-23','DD-MON-RR'),300       ,150);
INSERT INTO Medicine VALUES('M105','Anticoagulants'     ,'Prevent Blood Clotting'                           ,to_date('14-Aug-28','DD-MON-RR'),400       ,300);
INSERT INTO Medicine VALUES('M106','Leucovorin Calcium' ,'For Bowal Cancer'                                 ,to_date('18-Sep-26','DD-MON-RR'),90        ,500);
INSERT INTO Medicine VALUES('M107','IV Saline'          ,'For Replenish Lost Fluids'                        ,to_date('19-Dec-28','DD-MON-RR'),50        ,1000);
INSERT INTO Medicine VALUES('M108','Vitamin K'          ,'Makes Blood Clot'                                 ,to_date('13-Apr-26','DD-MON-RR'),10        ,1200);
INSERT INTO Medicine VALUES('M109','Ceftriaxone'        ,'Antibiotic for Bacterial Infections'              ,to_date('28-Dec-25','DD-MON-RR'),14        ,200);
INSERT INTO Medicine VALUES('M110','Cabozantinib'       ,'Used to treat Thyroid, Kidney and Liver Cancer'   ,to_date('02-Apr-27','DD-MON-RR'),250       ,360);
INSERT INTO Medicine VALUES('M111','TPF'                ,'Drug Combination for Stomach Cancer'              ,to_date('06-Apr-25','DD-MON-RR'),340       ,120);
INSERT INTO Medicine VALUES('M112','Megestrol Acetate'  ,'Treat Womb Cancer'                                ,to_date('17-Aug-25','DD-MON-RR'),28        ,300);

-- Data Insertion -> Medicine_Hx TABLE
INSERT INTO Medicine_Hx VALUES('M101','PA101',to_date('10-Jan-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M102','PA102',to_date('19-Mar-21','DD-MON-RR'),2);
INSERT INTO Medicine_Hx VALUES('M103','PA103',to_date('18-Jan-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M104','PA104',to_date('14-Feb-21','DD-MON-RR'),3);
INSERT INTO Medicine_Hx VALUES('M105','PA106',to_date('29-Jan-21','DD-MON-RR'),2);
INSERT INTO Medicine_Hx VALUES('M106','PA107',to_date('16-Feb-21','DD-MON-RR'),2);
INSERT INTO Medicine_Hx VALUES('M107','PA105',to_date('25-Mar-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M107','PA109',to_date('19-Feb-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M107','PA112',to_date('12-Mar-21','DD-MON-RR'),2);
INSERT INTO Medicine_Hx VALUES('M107','PA113',to_date('13-Mar-21','DD-MON-RR'),3);
INSERT INTO Medicine_Hx VALUES('M107','PA115',to_date('28-Jan-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M107','PA116',to_date('11-Feb-21','DD-MON-RR'),3);
INSERT INTO Medicine_Hx VALUES('M108','PA108',to_date('22-Mar-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M108','PA110',to_date('24-Feb-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M108','PA117',to_date('26-Feb-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M108','PA120',to_date('15-Mar-21','DD-MON-RR'),3);
INSERT INTO Medicine_Hx VALUES('M109','PA111',to_date('19-Mar-21','DD-MON-RR'),4);
INSERT INTO Medicine_Hx VALUES('M110','PA114',to_date('18-Mar-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M111','PA118',to_date('05-Feb-21','DD-MON-RR'),1);
INSERT INTO Medicine_Hx VALUES('M112','PA119',to_date('05-Feb-21','DD-MON-RR'),2);

-- Data Insertion -> Admission TABLE
INSERT INTO Admission VALUES('A101',to_date('06-Jan-21','DD-MON-RR'),NULL                               ,'PA101','BED101','N');
INSERT INTO Admission VALUES('A102',to_date('13-Jan-21','DD-MON-RR'),NULL                               ,'PA102','BED102','N');
INSERT INTO Admission VALUES('A103',to_date('09-Feb-21','DD-MON-RR'),NULL                               ,'PA103','BED103','N');
INSERT INTO Admission VALUES('A104',to_date('15-Mar-21','DD-MON-RR'),NULL                               ,'PA104','BED104','N');
INSERT INTO Admission VALUES('A105',to_date('21-Mar-21','DD-MON-RR'),NULL                               ,'PA105','BED105','N');
INSERT INTO Admission VALUES('A106',to_date('26-Jan-21','DD-MON-RR'),to_date('28-Feb-21','DD-MON-RR')   ,'PA106','BED106','Y');
INSERT INTO Admission VALUES('A107',to_date('11-Feb-21','DD-MON-RR'),NULL                               ,'PA107','BED107','N');
INSERT INTO Admission VALUES('A108',to_date('22-Mar-21','DD-MON-RR'),NULL                               ,'PA108','BED108','N');
INSERT INTO Admission VALUES('A109',to_date('15-Feb-21','DD-MON-RR'),to_date('15-Mar-21','DD-MON-RR')   ,'PA109','BED109','Y');
INSERT INTO Admission VALUES('A110',to_date('24-Feb-21','DD-MON-RR'),NULL                               ,'PA110','BED110','N');
INSERT INTO Admission VALUES('A111',to_date('14-Feb-21','DD-MON-RR'),to_date('14-Mar-21','DD-MON-RR')   ,'PA111','BED111','N');
INSERT INTO Admission VALUES('A112',to_date('06-Mar-21','DD-MON-RR'),NULL                               ,'PA112','BED112','N');
INSERT INTO Admission VALUES('A113',to_date('08-Mar-21','DD-MON-RR'),NULL                               ,'PA113','BED113','N');
INSERT INTO Admission VALUES('A114',to_date('14-Mar-21','DD-MON-RR'),NULL                               ,'PA114','BED114','N');
INSERT INTO Admission VALUES('A115',to_date('26-Jan-21','DD-MON-RR'),NULL                               ,'PA115','BED115','N');
INSERT INTO Admission VALUES('A116',to_date('06-Feb-21','DD-MON-RR'),NULL                               ,'PA116','BED116','N');
INSERT INTO Admission VALUES('A117',to_date('26-Feb-21','DD-MON-RR'),to_date('25-Mar-21','DD-MON-RR')   ,'PA117','BED117','N');
INSERT INTO Admission VALUES('A118',to_date('25-Jan-21','DD-MON-RR'),NULL                               ,'PA118','BED118','N');
INSERT INTO Admission VALUES('A119',to_date('22-Jan-21','DD-MON-RR'),NULL                               ,'PA119','BED119','N');
INSERT INTO Admission VALUES('A120',to_date('15-Mar-21','DD-MON-RR'),NULL                               ,'PA120','BED120','N');

-- Data Insertion -> Assignment TABLE
INSERT INTO Assignment VALUES('A101','SA111');
INSERT INTO Assignment VALUES('A101','SA118');
INSERT INTO Assignment VALUES('A102','SA116');
INSERT INTO Assignment VALUES('A103','SA102');
INSERT INTO Assignment VALUES('A104','SA116');
INSERT INTO Assignment VALUES('A105','SA111');
INSERT INTO Assignment VALUES('A106','SA112');
INSERT INTO Assignment VALUES('A106','SA116');
INSERT INTO Assignment VALUES('A107','SA102');
INSERT INTO Assignment VALUES('A108','SA111');
INSERT INTO Assignment VALUES('A109','SA120');
INSERT INTO Assignment VALUES('A110','SA116');
INSERT INTO Assignment VALUES('A111','SA111');
INSERT INTO Assignment VALUES('A112','SA117');
INSERT INTO Assignment VALUES('A113','SA112');
INSERT INTO Assignment VALUES('A114','SA102');
INSERT INTO Assignment VALUES('A115','SA118');
INSERT INTO Assignment VALUES('A116','SA116');
INSERT INTO Assignment VALUES('A117','SA102');
INSERT INTO Assignment VALUES('A118','SA111');
INSERT INTO Assignment VALUES('A119','SA102');
INSERT INTO Assignment VALUES('A120','SA116');

-- Data Update to resolve Circular Problem
UPDATE Department SET HOD_ID = 'SA106' WHERE Dept_ID = 'D101';
UPDATE Department SET HOD_ID = 'SA107' WHERE Dept_ID = 'D102';
UPDATE Department SET HOD_ID = 'SA102' WHERE Dept_ID = 'D103';
UPDATE Department SET HOD_ID = 'SA117' WHERE Dept_ID = 'D104';
UPDATE Department SET HOD_ID = 'SA103' WHERE Dept_ID = 'D105';
UPDATE Department SET HOD_ID = 'SA119' WHERE Dept_ID = 'D106';
UPDATE Department SET HOD_ID = 'SA104' WHERE Dept_ID = 'D107';

-- Misc Commands
COLUMN Med_Price    FORMAT $999,999.00;
COLUMN Trt_Price    FORMAT $999,999.00;
COLUMN Bed_Fee      FORMAT $999,999.00;
COLUMN S_Salary     FORMAT $999,999.00;
COLUMN Bill_Paid    FORMAT A9;
COLUMN S_SEX        FORMAT A9;
COLUMN P_SEX        FORMAT A9;
SET UNDERLINE '=';

-- Commit into the DB
COMMIT;

-- Test Prompt
prompt UCCD2203 - Hospital Database SQL Script Execution Completed...;