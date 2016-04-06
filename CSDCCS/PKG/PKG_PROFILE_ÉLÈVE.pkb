CREATE OR REPLACE PACKAGE BODY CSCFN.PKG_PROFILE_ÉLÈVE AS

FUNCTION get_person_phone_business (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);
cursor c3(p_person_id varchar2) is
    SELECT area_code, phone_no, extension
       FROM  person_telecom
       WHERE person_id = p_person_id
    AND  start_date <= a_effdate
    AND  (end_date  >= a_effdate OR end_date IS NULL)
    AND  email_type_flag = ' '
    AND  telecom_type_name = 'Business';
c3rec c3%rowtype;
begin

a_address_line:='';
open c3(a_person_id);
fetch c3 into c3rec;

if c3%FOUND THEN
    a_address_line := a_address_line ||'('|| c3rec.area_code ||')'|| c3rec.phone_no||' ';
else
    null;
end if;
close c3;

return a_address_line;

end get_person_phone_business;



function get_person_phone_cell (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);

cursor c3(p_person_id varchar2) is
    SELECT area_code, phone_no, extension
       FROM  person_telecom
       WHERE person_id = p_person_id
    AND  start_date <= a_effdate
    AND  (end_date  >= a_effdate OR end_date IS NULL)
    AND  email_type_flag = ' '
    AND  telecom_type_name = 'Cell';
c3rec c3%rowtype;
cursor c4 (p_person_id varchar2) is
    SELECT area_code, phone_no, extension
       FROM  person_telecom
       WHERE person_id = p_person_id
    AND  start_date <= a_effdate
    AND  (end_date  >= a_effdate OR end_date IS NULL)
    AND  email_type_flag = ' '
    AND  telecom_type_name = 'Cellulaire';
c4rec c4%rowtype;
begin

a_address_line:='';


open c3(a_person_id);
fetch c3 into c3rec;

if c3%FOUND THEN
    a_address_line := a_address_line ||'('|| c3rec.area_code ||')'|| c3rec.phone_no||' ';
end if;
close c3;

open c4(a_person_id);
fetch c4 into c4rec;

if c4%FOUND THEN
    a_address_line := a_address_line || '(' || c4rec.area_code ||')'||c4rec.phone_no||nvl('-'||c4rec.extension,'')||' ';
end if;
close c4;

return a_address_line;

end get_person_phone_cell;



function get_person_phone_home (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);
cursor c3(p_person_id varchar2) is
    SELECT area_code, phone_no, extension
       FROM  person_telecom
       WHERE person_id = p_person_id
    AND  start_date <= a_effdate
    AND  (end_date  >= a_effdate OR end_date IS NULL)
    AND  email_type_flag = ' '
    AND  telecom_type_name = 'Home';
c3rec c3%rowtype;
begin

a_address_line:='';
open c3(a_person_id);
fetch c3 into c3rec;

if c3%FOUND THEN
    a_address_line := a_address_line ||'('|| c3rec.area_code ||')'|| c3rec.phone_no||' ';
else
    null;
end if;
close c3;

return a_address_line;

end get_person_phone_home;



function get_pgc_address_home_1 (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);
cursor c0(p_person_id varchar2) is
  SELECT address_id
  from PERSON_ADDRESSES
  where person_id = p_person_id
  and address_type_name = 'Home'
  and a_effdate between start_date and nvl(end_date,a_effdate+1)
order by address_type_name desc;
cursor c1(a_address_id varchar2) is
  SELECT A.rural_address_flag,A.street_no,A.street_no_qualifier, A.street, A.unit_type_code
  , B.unit_type_code_f, C.system_parameter_value , A.unit_no, A.site, A.compartment
  , A.group_no, A.box, A.delivery_type, D.delivery_type_name_f, A.delivery_no
  , A.installation_type, E.installation_type_name_f, A.installation_no
    FROM
         ADDRESSES A, UNIT_TYPES B, SYSTEM_PARAMETERS C, FS_ADDRESS_DELIVERY_TYPE D
         , FS_ADDRESS_INSTALLATION_TYPE E
   WHERE  (A.address_id=a_address_id)
   and A.unit_type_code=B.unit_type_code (+)
   and C.system_parameter_code='LANGUAGE'
   and A.delivery_type=D.delivery_type_name (+)
   and A.installation_type=E.installation_type_name (+);
c1rec c1%rowtype;
c0rec c0%rowtype;
begin

a_address_line:='';

open c0(a_person_id);
fetch c0 into c0rec;

if c0%FOUND THEN

open c1(c0rec.address_id);
fetch c1 into c1rec;
if c1%FOUND THEN
    if c1rec.street_no is not null then
        a_address_line := a_address_line || c1rec.street_no;
    end if;

    if c1rec.street_no_qualifier is not null then
        a_address_line := a_address_line || ' ' || c1rec.street_no_qualifier;
    end if;

    if c1rec.street is not null then
        a_address_line := a_address_line || ' ' || c1rec.street;
    end if;

    if c1rec.system_parameter_value = 'French' then
        if c1rec.unit_type_code_f is not null then
            a_address_line := a_address_line || ', ' || c1rec.unit_type_code_f || ' ' ;
        end if;
    else
        if c1rec.unit_type_code is not null then
            a_address_line := a_address_line || ', ' || c1rec.unit_type_code || ' ';
        end if;
    end if;

    if c1rec.unit_no is not null then
        a_address_line := a_address_line || c1rec.unit_no ;
    end if;

    if c1rec.rural_address_flag = 'x' then
        if c1rec.site is not null then
            if c1rec.system_parameter_value = 'French' then
                a_address_line := a_address_line || ',' || 'Empl ' || c1rec.site || ', ';
            else
                a_address_line := a_address_line || ',' || 'Site ' || c1rec.site || ', ';
            end if;
        end if;

        if c1rec.compartment is not null then
            a_address_line := a_address_line || 'Comp '|| c1rec.compartment|| ', ';
        end if;

        if c1rec.group_no is not null then
            a_address_line := a_address_line || 'Group '||c1rec.group_no||', ';
        end if;

        if c1rec.box is not null then
            if c1rec.system_parameter_value='French' then
                a_address_line := a_address_line || 'Case ' ||c1rec.box||', ';
            else
                a_address_line := a_address_line || 'Box '||c1rec.box||', ';
            end if;
        end if;

        if c1rec.delivery_type is not null then
            if c1rec.system_parameter_value='French' then
                a_address_line := a_address_line || c1rec.delivery_type_name_f || ' ';
            else
                a_address_line := a_address_line || c1rec.delivery_type || ' ';
            end if;
        end if;

        if c1rec.delivery_no is not null then
            a_address_line := a_address_line || c1rec.delivery_no || ', ';
        end if;

        if c1rec.installation_type is not null then
            if c1rec.system_parameter_value='French' then
                a_address_line := a_address_line || c1rec.installation_type_name_f || ' ';
            else
                a_address_line := a_address_line || c1rec.installation_type || ' ';
            end if;
        end if;

        if c1rec.installation_no is not null then
            a_address_line := a_address_line || c1rec.installation_no || ', ';
        end if;
    end if;


END IF;

close c1;
END IF;
close c0;

return a_address_line;

end get_pgc_address_home_1;

function get_pgc_address_home_2 (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);
cursor c0(p_person_id varchar2) is
  SELECT address_id
  from PERSON_ADDRESSES
  where person_id = p_person_id
  and address_type_name = 'Home'
  and a_effdate between start_date and nvl(end_date,a_effdate+1)
order by address_type_name desc;
cursor c1(a_address_id varchar2) is
  SELECT A.jurisdiction_name, A.province_state_code, A.country_name, A.postal_code
    FROM
         ADDRESSES A, UNIT_TYPES B, SYSTEM_PARAMETERS C, FS_ADDRESS_DELIVERY_TYPE D
         , FS_ADDRESS_INSTALLATION_TYPE E
   WHERE  (A.address_id=a_address_id)
   and A.unit_type_code=B.unit_type_code (+)
   and C.system_parameter_code='LANGUAGE'
   and A.delivery_type=D.delivery_type_name (+)
   and A.installation_type=E.installation_type_name (+);
c1rec c1%rowtype;
c0rec c0%rowtype;
begin

a_address_line:='';

open c0(a_person_id);
fetch c0 into c0rec;

if c0%FOUND THEN

open c1(c0rec.address_id);
fetch c1 into c1rec;
if c1%FOUND THEN
    
    if c1rec.jurisdiction_name is not null then
        a_address_line := a_address_line || c1rec.jurisdiction_name || ', ';
    end if;

    if c1rec.province_state_code is not null then
        a_address_line := a_address_line || c1rec.province_state_code || ' ';
    end if;

END IF;

close c1;
END IF;
close c0;

return a_address_line;

end get_pgc_address_home_2;

function get_pgc_address_mail (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);
cursor c0(p_person_id varchar2) is
  SELECT address_id
  from PERSON_ADDRESSES
  where person_id = p_person_id
  and address_type_name = 'Mailing'
  and a_effdate between start_date and nvl(end_date,a_effdate+1)
order by address_type_name desc;
cursor c1(a_address_id varchar2) is
  SELECT A.rural_address_flag,A.street_no,A.street_no_qualifier, A.street, A.unit_type_code
  , B.unit_type_code_f, C.system_parameter_value , A.unit_no, A.site, A.compartment
  , A.group_no, A.box, A.delivery_type, D.delivery_type_name_f, A.delivery_no
  , A.installation_type, E.installation_type_name_f, A.installation_no
  , A.jurisdiction_name, A.province_state_code, A.country_name, A.postal_code
    FROM
         ADDRESSES A, UNIT_TYPES B, SYSTEM_PARAMETERS C, FS_ADDRESS_DELIVERY_TYPE D
         , FS_ADDRESS_INSTALLATION_TYPE E
   WHERE  (A.address_id=a_address_id)
   and A.unit_type_code=B.unit_type_code (+)
   and C.system_parameter_code='LANGUAGE'
   and A.delivery_type=D.delivery_type_name (+)
   and A.installation_type=E.installation_type_name (+);
c1rec c1%rowtype;
c0rec c0%rowtype;
begin

a_address_line:='';

open c0(a_person_id);
fetch c0 into c0rec;

if c0%FOUND THEN

open c1(c0rec.address_id);
fetch c1 into c1rec;
if c1%FOUND THEN
    if c1rec.street_no is not null then
        a_address_line := a_address_line || c1rec.street_no;
    end if;

    if c1rec.street_no_qualifier is not null then
        a_address_line := a_address_line || ' ' || c1rec.street_no_qualifier;
    end if;

    if c1rec.street is not null then
        a_address_line := a_address_line || ' ' || c1rec.street || ',';
    end if;

    if c1rec.system_parameter_value = 'French' then
        if c1rec.unit_type_code_f is not null then
            a_address_line := a_address_line ||  c1rec.unit_type_code_f || ' ' ;
        end if;
    else
        if c1rec.unit_type_code is not null then
            a_address_line := a_address_line ||  c1rec.unit_type_code || ' ';
        end if;
    end if;

    if c1rec.unit_no is not null then
        a_address_line := a_address_line || c1rec.unit_no || ',';
    end if;

    if c1rec.rural_address_flag = 'x' then
        if c1rec.site is not null then
            if c1rec.system_parameter_value = 'French' then
                a_address_line := a_address_line || 'Empl ' || c1rec.site || ', ';
            else
                a_address_line := a_address_line || 'Site ' || c1rec.site || ', ';
            end if;
        end if;

        if c1rec.compartment is not null then
            a_address_line := a_address_line || 'Comp '|| c1rec.compartment|| ', ';
        end if;

        if c1rec.group_no is not null then
            a_address_line := a_address_line || 'Group '||c1rec.group_no||', ';
        end if;

        if c1rec.box is not null then
            if c1rec.system_parameter_value='French' then
                a_address_line := a_address_line || 'Case ' ||c1rec.box||', ';
            else
                a_address_line := a_address_line || 'Box '||c1rec.box||', ';
            end if;
        end if;

        if c1rec.delivery_type is not null then
            if c1rec.system_parameter_value='French' then
                a_address_line := a_address_line || c1rec.delivery_type_name_f || ' ';
            else
                a_address_line := a_address_line || c1rec.delivery_type || ' ';
            end if;
        end if;

        if c1rec.delivery_no is not null then
            a_address_line := a_address_line || c1rec.delivery_no || ', ';
        end if;

        if c1rec.installation_type is not null then
            if c1rec.system_parameter_value='French' then
                a_address_line := a_address_line || c1rec.installation_type_name_f || ' ';
            else
                a_address_line := a_address_line || c1rec.installation_type || ' ';
            end if;
        end if;

        if c1rec.installation_no is not null then
            a_address_line := a_address_line || c1rec.installation_no || ', ';
        end if;
    end if;

    if c1rec.jurisdiction_name is not null then
        a_address_line := a_address_line || c1rec.jurisdiction_name || ', ';
    end if;

    if c1rec.province_state_code is not null then
        a_address_line := a_address_line || c1rec.province_state_code || ' ';
    end if;

    if c1rec.country_name is not null then
        a_address_line := a_address_line || c1rec.country_name || ' ';
    end if;

    if c1rec.postal_code is not null then
        if upper(c1rec.country_name)='CANADA' then
            a_address_line := a_address_line || upper(substr(c1rec.postal_code,1,3)) || ' ' ||
                        upper(substr(c1rec.postal_code,4,3));
        else
            a_address_line := a_address_line || c1rec.postal_code;
        end if;
    end if;


END IF;

close c1;
END IF;
close c0;

return a_address_line;

end get_pgc_address_mail;


function get_pgc_address_email (a_person_id varchar2, a_effdate date) return varchar2 is
a_address_line varchar2(200);
cursor c3(p_person_id varchar2) is
    SELECT email_account
       FROM  person_telecom
       WHERE person_id = p_person_id
    AND  start_date <= a_effdate
    AND  (end_date  >= a_effdate OR end_date IS NULL)
    AND  email_type_flag = 'x'
    AND  telecom_type_name = 'Internet';
c3rec c3%rowtype;
begin

a_address_line:='';
open c3(a_person_id);
fetch c3 into c3rec;

if c3%FOUND THEN
    a_address_line := a_address_line || c3rec.email_account;
else
    null;
end if;
close c3;

return a_address_line;

end get_pgc_address_email;


FUNCTION FIND_MAIN_CLASS_CODE (a_school_code varchar2, a_school_year varchar2, a_person_id varchar2, a_eff_date date) return varchar2 is

a_class_code school_classes.class_code%TYPE;

cursor c1 is
  SELECT student_program_class_tracks.class_code
    FROM
         student_program_class_tracks , school_classes
   WHERE  ( student_program_class_tracks.school_code = school_classes.school_code ) and
         ( student_program_class_tracks.school_year = school_classes.school_year ) and
         ( student_program_class_tracks.class_code = school_classes.class_code ) and
(student_program_class_tracks.school_code = a_school_code) AND
         (student_program_class_tracks.school_year = a_school_year) AND
         (student_program_class_tracks.person_id = a_person_id) AND
         (school_classes.class_homeroom_flag = 'p') AND
         (student_program_class_tracks.start_date <= a_eff_date ) AND
         (student_program_class_tracks.end_date >= a_eff_date OR
         student_program_class_tracks.end_date is null)
ORDER BY student_program_class_tracks.class_code ASC;
--
--       select c.class_code
--       from school_classes c, student_program_class_tracks t
--       where t.school_code = a_school_code
--       and t.school_year = a_school_year
--        and t.person_id = a_person_id
--       and c.school_code = t.school_code
--       and c.school_year = t.school_year
--       and c.class_code = t.class_code
--          and t.start_date <= a_eff_date
--          and nvl(t.end_date,a_eff_date) >= a_eff_date
--       order by decode(class_homeroom_flag, 'p',1,'a',2, 3);
c1rec c1%ROWTYPE;

begin


open c1;
fetch c1 into c1rec;
IF c1%FOUND THEN
       a_class_code := c1rec.class_code;
ELSE
    a_class_code := NULL;
END IF;

close c1;

return a_class_code;

end FIND_MAIN_CLASS_CODE;


FUNCTION FIND_MAIN_CLASS_ROOM_NO (a_school_code varchar2, a_school_year varchar2, a_person_id varchar2, a_eff_date date) return varchar2 is

a_room_no school_classes.ROOM_NO%TYPE;

cursor c1 is
  SELECT SCHOOL_CLASSES.ROOM_NO
    FROM
         student_program_class_tracks , school_classes
   WHERE  ( student_program_class_tracks.school_code = school_classes.school_code ) and
         ( student_program_class_tracks.school_year = school_classes.school_year ) and
         ( student_program_class_tracks.class_code = school_classes.class_code ) and
(student_program_class_tracks.school_code = a_school_code) AND
         (student_program_class_tracks.school_year = a_school_year) AND
         (student_program_class_tracks.person_id = a_person_id) AND
         (school_classes.class_homeroom_flag = 'p') AND
         (student_program_class_tracks.start_date <= a_eff_date ) AND
         (student_program_class_tracks.end_date >= a_eff_date OR
         student_program_class_tracks.end_date is null)
         
         
ORDER BY student_program_class_tracks.class_code ASC;
--
--       select c.class_code
--       from school_classes c, student_program_class_tracks t
--       where t.school_code = a_school_code
--       and t.school_year = a_school_year
--        and t.person_id = a_person_id
--       and c.school_code = t.school_code
--       and c.school_year = t.school_year
--       and c.class_code = t.class_code
--          and t.start_date <= a_eff_date
--          and nvl(t.end_date,a_eff_date) >= a_eff_date
--       order by decode(class_homeroom_flag, 'p',1,'a',2, 3);
c1rec c1%ROWTYPE;

begin


open c1;
fetch c1 into c1rec;
IF c1%FOUND THEN
       a_room_no := c1rec.ROOM_NO;
ELSE
     a_room_no := NULL;
END IF;

close c1;

return  a_room_no;

end FIND_MAIN_CLASS_ROOM_NO;

FUNCTION GET_SCHOOL_YEAR (pi_date in date) return varchar2 as
  vc_school_year          VARCHAR2(10);  
begin
 vc_school_year := case
              when to_number(to_char(pi_date,'MM')) = 7 then to_char(pi_date,'YYYY')||to_number(to_char(pi_date,'YYYY'))+1
              when to_number(to_char(pi_date,'MM')) = 8 then to_char(pi_date,'YYYY')||to_number(to_char(pi_date,'YYYY'))+1
              when to_number(to_char(pi_date,'MM')) = 9 then to_char(pi_date,'YYYY')||to_number(to_char(pi_date,'YYYY'))+1
              when to_number(to_char(pi_date,'MM')) = 10 then to_char(pi_date,'YYYY')||to_number(to_char(pi_date,'YYYY'))+1
              when to_number(to_char(pi_date,'MM')) = 11 then to_char(pi_date,'YYYY')||to_number(to_char(pi_date,'YYYY'))+1
              when to_number(to_char(pi_date,'MM')) = 12 then to_char(pi_date,'YYYY')||to_number(to_char(pi_date,'YYYY'))+1
              else to_number(to_char(pi_date,'YYYY'))-1||to_char(pi_date,'YYYY')
            end;
 return vc_school_year;
end GET_SCHOOL_YEAR;


FUNCTION GET_TEACHER_NAME (a_person_id varchar2) RETURN VARCHAR2 IS
cursor c1 is
    select salutation_code || ' '|| LEGAL_NAME_UPPER "teacher_name"
    from persons
    where person_id = a_person_id;
o_teacher_name varchar2(70);
begin
    open c1;
    fetch c1 into o_teacher_name;
    close c1;

    return o_teacher_name;
end GET_TEACHER_NAME;

FUNCTION FIND_MAIN_CLASS_TEACHER (a_school_code varchar2, a_school_year varchar2, a_person_id varchar2, a_eff_date date) return varchar2 is

a_rep_teacher school_classes.REPORTING_TEACHER%TYPE;

cursor c1 is
  SELECT SCHOOL_CLASSES.REPORTING_TEACHER
    FROM
         student_program_class_tracks , school_classes
   WHERE  ( student_program_class_tracks.school_code = school_classes.school_code ) and
         ( student_program_class_tracks.school_year = school_classes.school_year ) and
         ( student_program_class_tracks.class_code = school_classes.class_code ) and
(student_program_class_tracks.school_code = a_school_code) AND
         (student_program_class_tracks.school_year = a_school_year) AND
         (student_program_class_tracks.person_id = a_person_id) AND
         (school_classes.class_homeroom_flag = 'p') AND
         (student_program_class_tracks.start_date <= a_eff_date ) AND
         (student_program_class_tracks.end_date >= a_eff_date OR
         student_program_class_tracks.end_date is null)
         
         
ORDER BY student_program_class_tracks.class_code ASC;
--
--       select c.class_code
--       from school_classes c, student_program_class_tracks t
--       where t.school_code = a_school_code
--       and t.school_year = a_school_year
--        and t.person_id = a_person_id
--       and c.school_code = t.school_code
--       and c.school_year = t.school_year
--       and c.class_code = t.class_code
--          and t.start_date <= a_eff_date
--          and nvl(t.end_date,a_eff_date) >= a_eff_date
--       order by decode(class_homeroom_flag, 'p',1,'a',2, 3);
c1rec c1%ROWTYPE;

begin


open c1;
fetch c1 into c1rec;
IF c1%FOUND THEN
       a_rep_teacher := c1rec.REPORTING_TEACHER;
ELSE
     a_rep_teacher := NULL;
END IF;

close c1;

return  a_rep_teacher;

end FIND_MAIN_CLASS_TEACHER;

FUNCTION GET_PEI(A_PERSON_ID VARCHAR2) RETURN VARCHAR2 IS
-- noté le 25 mars 2013--Le PEI est indiquer dasn la table student_course_strand_achieve pour chaque domaine pour les 1ire à 8ieme.  Student_course_Achieve semble ^tre réservé pour MAT/JAR
--Avec la consigne de serge nous allons tirer le PEI de la table Student_registrations
--les arguments A_REPORT_PERIOD, A_SUBJECT_CODE ne son plus nécéssaire
--NOTÉ le 2 décembre 2014 nous avons faits des recherches et avons identifiés que le PEI est maintenant retirer de FS_SE_STUDENT_SETTINGS

O_PEI VARCHAR2(5) := NULL;
O_COUNT_ACTIF number;
O_COUNT_VIEUX number;
BEGIN
SELECT count(*) INTO O_COUNT_ACTIF FROM FS_SE_STUDENT_SETTINGS WHERE
PERSON_ID = A_PERSON_ID AND 
IEP_10 = 1 AND 
END_DATE IS NULL OR
END_DATE >= SYSDATE;

SELECT COUNT(*) INTO O_COUNT_VIEUX FROM FS_SE_STUDENT_SETTINGS WHERE
PERSON_ID = A_PERSON_ID;

if O_COUNT_ACTIF >= 1 then
        O_PEI := 'Oui';
        
elsif O_COUNT_VIEUX >= 1 THEN 
        O_PEI := 'Démit';
else
        O_PEI := 'Non';
end if;

RETURN NVL(O_PEI,'');

END GET_PEI;

FUNCTION GET_ANOMALIE(A_PERSON_ID VARCHAR2) RETURN VARCHAR2 IS
--NOTÉ le 2 décembre 2014 ajouté pour combler les besoins du rapports

O_ANOMALIE VARCHAR2(50) := NULL;
ROW_COUNT_ACTIF NUMBER := NULL;
ROW_COUNT_VIEUX NUMBER := NULL;

BEGIN
SELECT COUNT(*) INTO ROW_COUNT_ACTIF
FROM FS_SE_STUDENT_EXCEPTIONALITIES fs, persons p, EXCEPTIONALITIES e 
WHERE 
fs.person_id = p.person_id 
AND fs.exceptionality_id = e.exceptionality_id 
AND p.person_id = A_PERSON_ID 
AND (fs.end_date IS NULL OR fs.end_date >= SYSDATE);

SELECT COUNT(*) INTO ROW_COUNT_VIEUX
FROM FS_SE_STUDENT_EXCEPTIONALITIES fs, persons p, EXCEPTIONALITIES e 
WHERE 
fs.person_id = p.person_id 
AND fs.exceptionality_id = e.exceptionality_id 
AND p.person_id = A_PERSON_ID;

IF ROW_COUNT_ACTIF >= 1 THEN
    SELECT e.short_Name_f INTO O_ANOMALIE 
    FROM FS_SE_STUDENT_EXCEPTIONALITIES fs, persons p, EXCEPTIONALITIES e 
    WHERE 
    fs.person_id = p.person_id 
    AND fs.exceptionality_id = e.exceptionality_id 
    AND p.person_id = A_PERSON_ID 
    AND (fs.end_date IS NULL OR fs.end_date >= SYSDATE);
        
ELSIF 
    ROW_COUNT_VIEUX >= 1 THEN
    O_ANOMALIE := 'Démit';

ELSE 
    O_ANOMALIE := '';
end if;

RETURN O_ANOMALIE;

END GET_ANOMALIE;

FUNCTION GET_ALF(A_PERSON_ID VARCHAR2) RETURN VARCHAR2 IS
-- modifier le 25 mars 2013 nous alon tirer le statu de la table FS_STUDENT_FSL_PROGRAM--

O_ALF VARCHAR2(10) := NULL;
O_COUNT_ACTIF NUMBER := 0;
O_COUNT_VIEUX NUMBER := 0;

BEGIN

SELECT count(*) into O_COUNT_ACTIF FROM fs_student_fsl_programs WHERE
PERSON_ID = A_PERSON_ID
AND SYSDATE BETWEEN START_DATE AND END_DATE;

SELECT COUNT(*) INTO O_COUNT_VIEUX FROM FS_STUDENT_FSL_PROGRAMS WHERE
PERSON_ID = A_PERSON_ID;


if O_COUNT_ACTIF = 1 then
        select OTHER_FSL_INSTRUCTION into o_alf
        FROM FS_STUDENT_FSL_PROGRAMS 
        WHERE PERSON_ID = A_PERSON_ID
        and end_date > sysdate;
        
elsif O_COUNT_VIEUX >= 1 THEN 
        O_ALF := 'Démit';
else
        O_ALF := 'Non';
end if;

RETURN NVL(O_ALF,'N/A');

END GET_ALF;

FUNCTION GET_LAST_IPRC_DATE(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2) RETURN VARCHAR2 IS
-- modifier le 25 mars 2013 nous alon tirer le statu de la table FS_STUDENT_FSL_PROGRAM--
DATE_CIPR varchar2(20) := null;

BEGIN

SELECT MAX(a.LAST_IPRC_REVIEW_DATE) into DATE_CIPR FROM trill02.VW_BG_SPED a WHERE
SCHOOL_YEAR = A_SCHOOL_YEAR AND 
SCHOOL_CODE = A_SCHOOL_CODE AND
PERSON_ID = A_PERSON_ID;

RETURN NVL(DATE_CIPR,'Aucune');

END GET_LAST_IPRC_DATE;


FUNCTION GBP_TAUX_PRECISION(A_RES_ID VARCHAR2) RETURN number IS 
/***************************************************************
Cette fonction calcule le taux de précision d'un élève. c'est
à dire le nombre d'erreur divisé par le nombre de mots dans le 
texte.
Ce taux est essentiellement la marge d'erreur, donc, on le
 soustrait de 100, pour donner le pourcentage exact...

À noter que ce taux ne serait pas toujour exact. Il est possible
que l'enseignant(e) ait décider de demander à l'élève de lire
moins de mot que le texte entier. 
****************************************************************/

PERCENTAGE number := 0;

BEGIN


select round((t.no_mots - sum(eac.e))/t.no_mots*100,2) into PERCENTAGE
from atelier.gbp_resultats_erreurs_ac eac,
     ATELIER.GBP_RESULTATS res,
     atelier.gbp_textes t
where eac.resultat_id = A_RES_ID
and eac.resultat_id = res.resultat_id
and t.texte_id = res.texte_id
group by t.no_mots;


RETURN PERCENTAGE;
END GBP_TAUX_PRECISION;

FUNCTION GBP_ERREURS(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.e) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_ERREURS;

FUNCTION GBP_ERREURS_S(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.e_s) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_ERREURS_S;

FUNCTION GBP_ERREURS_ST(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.e_st) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_ERREURS_ST;

FUNCTION GBP_ERREURS_V(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.e_v) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_ERREURS_V;

FUNCTION GBP_AC_SUM(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
AC varchar2(50) := null;

BEGIN

select sum(eac.ac) into AC 
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN AC;
END GBP_AC_SUM;
FUNCTION GBP_AC(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
AC varchar2(50) := null;

BEGIN

select sum(eac.ac) into AC 
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

if to_number(AC) > 0 then
select round((sum(eac.ac)+sum(eac.e))/sum(eac.ac),1) INTO AC
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

end if;

RETURN AC;
END GBP_AC;

FUNCTION GBP_AC_S(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.ac_s) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_AC_S;

FUNCTION GBP_AC_ST(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.ac_st) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_AC_ST;

FUNCTION GBP_AC_V(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
ERREURS varchar2(10) := null;

BEGIN

select sum(eac.ac_v) INTO ERREURS
from atelier.gbp_resultats_erreurs_ac eac
where eac.resultat_id = A_RES_ID;

RETURN ERREURS;
END GBP_AC_V;

FUNCTION GBP_NIVEAU_LECTURE(A_RES_ID VARCHAR2) RETURN VARCHAR2 IS 
NIVEAU varchar2(10) := null;

BEGIN

select 

CASE
    WHEN (MAX(100-(ROUND(SUM(eac.e)*100/(t.no_mots), 2)))) > 95
    THEN 'FACILE'
    
    WHEN (MAX(100-(ROUND(SUM(eac.e)*100/(t.no_mots), 2)))) <= 95 AND (MAX(100-(ROUND(SUM(eac.e)*100/(t.no_mots), 2)))) >= 90
    THEN 'INSTRUCTIF'
    
    WHEN (MAX(100-(ROUND(SUM(eac.e)*100/(t.no_mots), 2)))) < 90
    THEN 'DIFFICILE'
    
    ELSE '??'
    
END into NIVEAU

from atelier.gbp_resultats_erreurs_ac eac,
     ATELIER.GBP_RESULTATS res, 
     atelier.gbp_textes t
where eac.resultat_id = A_RES_ID
and t.texte_id = res.texte_id
group by t.no_mots;


RETURN NIVEAU;
END GBP_NIVEAU_LECTURE;

FUNCTION GBP_GET_NUM_QUE(AN_ID VARCHAR2, A_CAT VARCHAR2) RETURN NUMBER IS 
/***************************************************************************
*   Prend le numéro d'identification du *résultat* et non de la question   *
*   ainsi que le numéro de la catégorie où :                               *
*           1 -> Compréhension litérale                                    *
*           2 -> Compréhension déductive                                   *
*           3 -> Rappel du texte                                           *
***************************************************************************/
NUM_QUES NUMBER := NULL;

BEGIN
select count(r.question_id) INTO NUM_QUES
from atelier.gbp_comprehension_reponses r, atelier.gbp_comprehension_questions q
where resultat_id = AN_ID
and r.question_id = q.question_id
and q.cat_id = A_CAT;

RETURN NUM_QUES;
END GBP_GET_NUM_QUE;

FUNCTION GBP_GET_NUM_BONNES_REPONSES(AN_ID VARCHAR2, A_CAT VARCHAR2) RETURN NUMBER IS
/***************************************************************************
*   Prend le numéro d'identification du *résultat* et non de la question   *
*   ainsi que le numéro de la catégorie où :                               *
*           1 -> Compréhension litérale                                    *
*           2 -> Compréhension déductive                                   *
*           3 -> Rappel du texte                                           *
***************************************************************************/

NUM_BONNES_REPONSES NUMBER := NULL;

BEGIN
select count(CASE WHEN UPPER(REPONSE) = 'X' THEN REPONSE END) INTO NUM_BONNES_REPONSES
from atelier.gbp_comprehension_reponses r, atelier.gbp_comprehension_questions q
where resultat_id = AN_ID
and r.question_id = q.question_id
and q.cat_id = A_CAT;

RETURN NUM_BONNES_REPONSES;
END GBP_GET_NUM_BONNES_REPONSES;

FUNCTION GBP_GET_DENOMINATOR(AN_ID VARCHAR) RETURN NUMBER IS
NUM_1 NUMBER := NULL;
NUM_2 NUMBER := NULL;
NUM_3 NUMBER := NULL;
DENOMINATOR NUMBER := 0;

BEGIN

Select  count(case when q.cat_id = 1 then r.question_id end), 
        count(case when q.cat_id = 2 then r.question_id end),
        count(case when q.cat_id = 3 then r.question_id end) INTO NUM_1, NUM_2, NUM_3
from atelier.gbp_comprehension_reponses r, atelier.gbp_comprehension_questions q
where resultat_id = AN_ID
and r.question_id = q.question_id;

    IF(NUM_1 > 0) THEN 
        DENOMINATOR := DENOMINATOR + 1;
    END IF;
    IF(NUM_2 > 0) THEN
        DENOMINATOR := DENOMINATOR + 1;
    END IF;
    IF(NUM_3 > 0) THEN 
        DENOMINATOR := DENOMINATOR + 1;
    END IF;
    IF DENOMINATOR = 0 THEN 
        DENOMINATOR := 1;
    END IF;

RETURN DENOMINATOR;
END GBP_GET_DENOMINATOR;

FUNCTION GBP_GET_RECS (AN_ID VARCHAR2) RETURN VARCHAR IS
RECS VARCHAR2(500) := NULL;

BEGIN

--Le ListAgg aggregate toutes les recommandations ensemble qui sont associés à cet
--  élève afin qu'il retourne une rangé au lieu de une pour chaque recommendation
--REGEX à OZMIKE de StackOverflow modifié 
--  pour imprimer seulement une copie de chaque recommendation
SELECT replace(regexp_replace(
            LISTAGG(rec.rec_description, ';;') WITHIN GROUP (order by rec.rec_id),
            '([^;]+)(;\1)+', '\1'), ';', chr(10)
            ) INTO RECS 

    FROM ATELIER.GBP_RESULTATS       res,
     ATELIER.GBP_RECOMMANDATIONS     rec,
     ATELIER.GBP_RESULTATS_RECS      rr

    WHERE rec.rec_id = rr.rec_id
    AND rr.resultat_id = res.resultat_id
    AND res.resultat_id = AN_ID

    GROUP BY res.evaluation_date, res.niveau, res.resultat_id;

RETURN RECS;
END GBP_GET_RECS;

FUNCTION GBP_GET_RAPPEL (AN_ID VARCHAR2) RETURN NUMBER IS
RAPPEL NUMBER := NULL;

BEGIN

SELECT COUNT(REPONSE) INTO RAPPEL 
FROM ATELIER.GBP_ANALYSE_REPONSES
WHERE RESULTAT_ID = AN_ID
and reponse = 'x';

RETURN RAPPEL; 
END GBP_GET_RAPPEL;
    
FUNCTION GBP_GET_EVAL_DATE (A_PID VARCHAR2) RETURN DATE IS
EVAL_DATE DATE := NULL;

BEGIN

SELECT DISTINCT EVALUATION_DATE INTO EVAL_DATE
FROM ATELIER.GBP_RESULTATS 
WHERE ((EVALUATION_DATE = 
        (SELECT MAX (EVALUATION_DATE) FROM ATELIER.GBP_RESULTATS res
            WHERE res.PERSON_ID = A_PID)) 
     or EVALUATION_DATE is null)
     
     and evaluation_date is not null;
     
RETURN EVAL_DATE;
END GBP_GET_EVAL_DATE;

FUNCTION GBP_ATTENTE_EXPRESSIVE(A_RESULTAT_ID VARCHAR2) RETURN VARCHAR2 IS
O_REPONSE VARCHAR2(1) := NULL;

BEGIN

select 
nvl(reponse, ' ') INTO O_REPONSE

from atelier.GBP_COMPORTEMENTS_REPONSES

where resultat_id = A_RESULTAT_ID 
and attente_id in (
'589', '593', '597', '601',
'605', '609', '613', '617',
'621', '625', '629', '633',
'637', '641', '645', '649',
'653', '657', '661', '665',
'669', '673', '677', '681',
'685', '689', '693', '697',
'701', '705', '709', '713',
'717', '721', '725', '729',
'733', '737', '741', '745',
'749', '753', '757', '761',
'765', '769' );

RETURN O_REPONSE;
END GBP_ATTENTE_EXPRESSIVE;

FUNCTION GBP_ATTENTE_GROUPE_SIGNIFIANT(A_RESULTAT_ID VARCHAR2) RETURN VARCHAR2 IS
O_REPONSE VARCHAR2(1) := NULL;

BEGIN

select 
nvl(reponse, ' ') INTO O_REPONSE

from atelier.GBP_COMPORTEMENTS_REPONSES

where resultat_id = A_RESULTAT_ID 
and attente_id in (
'590', '594', '598', '602',
'606', '610', '614', '618',
'622', '626', '630', '634',
'638', '642', '646', '650',
'654', '658', '662', '666', 
'670', '674', '678', '682', 
'686', '690', '694', '698',
'702', '706', '710', '714',
'718', '722', '726', '730',
'734', '738', '742', '746',
'750', '754', '758', '762',
'766', '770'  );

RETURN O_REPONSE;
END GBP_ATTENTE_GROUPE_SIGNIFIANT;

FUNCTION GBP_ATTENTE_PONCTUATION(A_RESULTAT_ID VARCHAR2) RETURN VARCHAR2 IS
O_REPONSE VARCHAR2(1) := NULL;

BEGIN

select 
nvl(reponse, ' ') INTO O_REPONSE

from atelier.GBP_COMPORTEMENTS_REPONSES

where resultat_id = A_RESULTAT_ID 
and attente_id in (
'591', '595', '599', '603',
'607', '611', '615', '619',
'623', '627', '631', '635',
'639', '643', '647', '651',
'655', '659', '663', '667',
'671', '675', '679', '683',
'687', '691', '695', '699',
'703', '707', '711', '715',
'719', '723', '727', '731',
'735', '739', '743', '747',
'751', '755', '759', '763', 
'767', '771'  );

RETURN O_REPONSE;
END GBP_ATTENTE_PONCTUATION;

FUNCTION GBP_ATTENTE_LEC_COURANTE(A_RESULTAT_ID VARCHAR2) RETURN VARCHAR2 IS
O_REPONSE VARCHAR2(1) := NULL;

BEGIN

select 
nvl(reponse, ' ') INTO O_REPONSE

from atelier.GBP_COMPORTEMENTS_REPONSES

where resultat_id = A_RESULTAT_ID 
and attente_id in (
'592', '596', '600', '604',
'608', '612', '616', '620',
'624', '628', '632', '636',
'640', '644', '648', '652',
'656', '660', '664', '668',
'672', '676', '680', '684',
'688', '692', '696', '700',
'704', '708', '712', '716',
'720', '724', '728', '732', 
'736', '740', '744', '748',
'752', '756', '760', '764',
'768', '772' ); 

RETURN O_REPONSE;
END GBP_ATTENTE_LEC_COURANTE;

FUNCTION GET_COURSE_COUNT(A_SCHOOL_YEAR VARCHAR2, A_PERSON_ID VARCHAR2, A_SEMESTER VARCHAR2) RETURN NUMBER IS
NUM_COURSE NUMBER := NULL;

BEGIN 

SELECT
       COUNT( CASE --total des cours prit durant le semestre spécifié
              WHEN SEMESTER = A_SEMESTER 
              THEN SEMESTER END) AS SEMESTRE INTO NUM_COURSE
        
FROM (SELECT DISTINCT SCT.SCHOOL_YEAR, 
                SCT.COURSE_CODE || '-' || SCT.COURSE_SECTION AS COURSE, 
                SC.TAKE_ATTENDANCE_FLAG, CM.SEMESTER
                
FROM SCHOOL_CLASSES SC, STUDENT_PROGRAM_CLASS_TRACKS SCT, CLASS_MEETINGS CM 
                                
WHERE SCT.PERSON_ID = A_PERSON_ID
    AND SCT.SCHOOL_CODE IN ('ESF', 'ESA', 'ESE')
    AND SC.SCHOOL_CODE = SCT.SCHOOL_CODE
    AND SCT.SCHOOL_YEAR = A_SCHOOL_YEAR
    AND SC.SCHOOL_YEAR = SCT.SCHOOL_YEAR
    AND SC.CLASS_CODE = SCT.CLASS_CODE
    AND SCT.SCHOOL_CODE = CM.SCHOOL_CODE
    AND SCT.CLASS_CODE = CM.CLASS_CODE
    AND CM.SCHOOL_YEAR = SCT.SCHOOL_YEAR
    AND SCT.SCHOOL_YEAR_TRACK = CM.SCHOOL_YEAR_TRACK
    AND SCT.DEMIT_INDICATOR NOT IN ('9')


ORDER BY SCT.SCHOOL_YEAR, CM.SEMESTER, COURSE);


RETURN NUM_COURSE;
END GET_COURSE_COUNT;

FUNCTION GET_NOTE_COURS_SEC(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2, A_COURSE_CODE VARCHAR2, A_COURSE_CODE_SECT VARCHAR2 ) RETURN VARCHAR2 IS  
--cette fonction retourne une note pour un cours avec les paramêtre si dessus
O_MARK VARCHAR2(50);
BEGIN
SELECT F.MARK INTO O_MARK --CHANGÉ LE 04-06-2015 : UN NULL RETOURNAIT '?' AVANT
FROM FS_SECONDARY_COURSE_ACHIEVE F
WHERE
F.PERSON_ID = A_PERSON_ID
AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
AND F.SCHOOL_CODE = A_SCHOOL_CODE         
AND F.COURSE_CODE = A_COURSE_CODE
AND F.COURSE_SECTION = A_COURSE_CODE_SECT
AND F.REPORT_PERIOD = A_REPORT_PERIOD;
RETURN O_MARK;
END GET_NOTE_COURS_SEC;

FUNCTION GET_NOTE_ELE(a_person_id varchar2, a_school_year varchar2, a_report_period varchar2, a_strand_code varchar2 ) RETURN varchar2 IS  
--cette fonction retourne LA DATE DE DÉBUT D'UN TERM DEMANDÉ (p.PERSON_ID, sr.school_year, '2','003' )

O_NOTE_BULLETIN VARCHAR2(3);
O_NIV_RENDEMENT  VARCHAR2(3) := null;
O_COUNT NUMBER := 0;

V_YEAR VARCHAR2(3);
V_REPORT_PERIOD VARCHAR2(3);
R_RESULTATS VARCHAR2(3);

BEGIN
--        V_YEAR := CASE
--        WHEN To_Number(A_SCHOOL_YEAR) >= 20102011 THEN 'PIF'
--        ELSE '123'
--        END;
--        
--IF V_YEAR = '123' THEN
--    V_REPORT_PERIOD := CASE 
--    WHEN a_report_period = 'I' THEN '2'
--    WHEN a_report_period = 'F' THEN '3'
--    WHEN a_report_period = 'P' THEN '1' 
--    END;
--ELSE 
--    V_REPORT_PERIOD := a_report_period;
--END IF;

SELECT COUNT(*) INTO O_COUNT 
 FROM STUDENT_COURSE_STRAND_ACHIEVE
    WHERE PERSON_ID = A_PERSON_ID
   -- and school_code = a_school_code
    AND SCHOOL_YEAR = A_SCHOOL_YEAR
    AND REPORT_PERIOD = A_REPORT_PERIOD
    AND STRAND_CODE = A_STRAND_CODE
    AND MARK IS NOT NULL;

IF O_COUNT = 1 THEN 
    SELECT MARK INTO R_RESULTATS
        FROM STUDENT_COURSE_STRAND_ACHIEVE
        WHERE PERSON_ID = A_PERSON_ID
       -- and school_code = a_school_code  ENLEVÉ POUR LES DONNÉES HISTORIQUE
        AND SCHOOL_YEAR = A_SCHOOL_YEAR
        AND REPORT_PERIOD = A_REPORT_PERIOD
        AND STRAND_CODE = A_STRAND_CODE
        AND MARK IS NOT NULL;
ELSE 
    IF O_COUNT > 1 THEN --CECI AVAIT UNE CONDITION QUI VÉRIFIAIT LES NULLS ET LES REMPLACAIT AVEC '?'. 
    R_RESULTATS := '!';  --CETTE INSTRUCTION FUT ENLEVÉ POUR ACCOMODER LES RAPPORT JASPER LE 05-06-2015
    END IF; 
END IF;
    
RETURN R_RESULTATS;
                         
END GET_NOTE_ELE;

FUNCTION GET_REPORT_PERIOD_ABS(a_person_id varchar2, a_school_year varchar2, a_school_code varchar2, a_report_period varchar2 ) RETURN varchar2 IS  
--cette fonction retourne Les absences par rapport à la période de rapport.

O_COUNT number := 0;

V_YEAR VARCHAR2(5);
V_REPORT_PERIOD VARCHAR2(5);
R_RESULTATS VARCHAR2(5);

BEGIN
--        V_YEAR := CASE
--        WHEN To_Number(A_SCHOOL_YEAR) >= 20102011 THEN 'PIF'
--        ELSE '123'
--        END;
--        
--IF V_YEAR = '123' THEN
--    V_REPORT_PERIOD := CASE 
--    WHEN a_report_period = 'P' THEN '1'
--    WHEN a_report_period = 'I' THEN '2'
--    WHEN a_report_period = 'F' THEN '3'
--    END;
--ELSE 
--    V_REPORT_PERIOD := a_report_period;
--END IF;

SELECT COUNT(*) INTO O_COUNT 
    from student_achievement   
    WHERE person_id = A_PERSON_ID
    AND school_code = A_SCHOOL_CODE 
    AND school_year = A_SCHOOL_YEAR 
    AND report_period = A_REPORT_PERIOD;
    

IF O_COUNT = 1 THEN 
    SELECT YTD_ABSENCES INTO R_RESULTATS
    from student_achievement   
    WHERE person_id = A_PERSON_ID
    AND school_code = A_SCHOOL_CODE 
    AND school_year = A_SCHOOL_YEAR 
    AND report_period = A_REPORT_PERIOD;
ELSE 
    IF O_COUNT > 1 THEN --CECI AVAIT UNE CONDITION QUI VÉRIFIAIT LES NULLS ET LES REMPLACAIT AVEC '?'. 
    R_RESULTATS := '!';  --CETTE INSTRUCTION FUT ENLEVÉ POUR ACCOMODER LES RAPPORT JASPER LE 05-06-2015
    END IF; 
END IF;
    
RETURN R_RESULTATS;
                         
END GET_REPORT_PERIOD_ABS;

FUNCTION GET_REPORT_PERIOD_LATES(a_person_id varchar2, a_school_year varchar2, a_school_code varchar2, a_report_period varchar2 ) RETURN varchar2 IS  
--cette fonction retourne Les absences par rapport à la période de rapport.

O_COUNT NUMBER := 0;

V_YEAR VARCHAR2(5);
V_REPORT_PERIOD VARCHAR2(5);
R_RESULTATS VARCHAR2(5);

BEGIN
--        V_YEAR := CASE
--        WHEN To_Number(A_SCHOOL_YEAR) >= 20102011 THEN 'PIF'
--        ELSE '123'
--        END;
--        
--IF V_YEAR = '123' THEN
--    V_REPORT_PERIOD := CASE 
--    WHEN a_report_period = 'P' THEN '1'
--    WHEN a_report_period = 'I' THEN '2'
--    WHEN a_report_period = 'F' THEN '3'
--    END;
--ELSE 
--    V_REPORT_PERIOD := a_report_period;
--END IF;

SELECT COUNT(*) INTO O_COUNT 
    from student_achievement   
    WHERE person_id = A_PERSON_ID
    AND school_code = A_SCHOOL_CODE 
    AND school_year = A_SCHOOL_YEAR 
    AND report_period = A_REPORT_PERIOD;
    

IF O_COUNT = 1 THEN 
    SELECT LATES INTO R_RESULTATS
    from student_achievement   
    WHERE person_id = A_PERSON_ID
    AND school_code = A_SCHOOL_CODE 
    AND school_year = A_SCHOOL_YEAR 
    AND report_period = A_REPORT_PERIOD;
ELSE 
    IF O_COUNT > 1 THEN --CECI AVAIT UNE CONDITION QUI VÉRIFIAIT LES NULLS ET LES REMPLACAIT AVEC '?'. 
    R_RESULTATS := '!';  --CETTE INSTRUCTION FUT ENLEVÉ POUR ACCOMODER LES RAPPORT JASPER LE 05-06-2015
    END IF; 
END IF;
    
RETURN R_RESULTATS;
                         
END GET_REPORT_PERIOD_LATES;

FUNCTION GET_ABS_COURS_SEC(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_SEMESTRE VARCHAR2, A_COURSE_CODE VARCHAR2, A_COURSE_CODE_SECT VARCHAR2 ) RETURN VARCHAR2 IS  
--cette fonction retourne les absence pour un cours avec les paramêtre si dessus
O_ABS VARCHAR2(5);
BEGIN
SELECT NVL(F.SUBJECT_ABSENCES,'0') INTO O_ABS
FROM FS_SECONDARY_COURSE_ACHIEVE F
WHERE
F.PERSON_ID = A_PERSON_ID
AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
AND F.SCHOOL_CODE = A_SCHOOL_CODE         
AND F.COURSE_CODE = A_COURSE_CODE
AND F.COURSE_SECTION = A_COURSE_CODE_SECT
AND F.REPORT_PERIOD in (A_SEMESTRE||'F');

RETURN O_ABS;
END GET_ABS_COURS_SEC;

FUNCTION GET_RET_COURS_SEC(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_SEMESTRE VARCHAR2, A_COURSE_CODE VARCHAR2, A_COURSE_CODE_SECT VARCHAR2 ) RETURN VARCHAR2 IS
--cette fonction retourne les retards pour un cours avec les paramêtre si dessus
O_RET VARCHAR2(3);
BEGIN
SELECT NVL(SUM(F.SUBJECT_LATES),'0') INTO O_RET
FROM FS_SECONDARY_COURSE_ACHIEVE F
WHERE
F.PERSON_ID = A_PERSON_ID
AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
AND F.SCHOOL_CODE = A_SCHOOL_CODE         
AND F.COURSE_CODE = A_COURSE_CODE
AND F.COURSE_SECTION = A_COURSE_CODE_SECT
AND F.REPORT_PERIOD in (A_SEMESTRE||'M',A_SEMESTRE||'F');

RETURN O_RET;
END GET_RET_COURS_SEC;

FUNCTION GET_COTE_HH_SEC(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2, A_COURSE_CODE VARCHAR2, A_COURSE_CODE_SECT VARCHAR2, A_HH VARCHAR2 ) RETURN VARCHAR2 IS  
--cette fonction retourne une COTE pour un hh avec les paramêtre si dessus
V_COTE VARCHAR2(50);
R_SCA FS_SECONDARY_COURSE_ACHIEVE%ROWTYPE;
C INTEGER; 

BEGIN

SELECT COUNT(*) INTO C  --ON VEUX S'ASSURER QU'ON A SEULEMENT 1 RECORD
FROM FS_SECONDARY_COURSE_ACHIEVE F
WHERE
F.PERSON_ID = A_PERSON_ID
AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
AND F.SCHOOL_CODE = A_SCHOOL_CODE         
AND F.COURSE_CODE = A_COURSE_CODE
AND F.COURSE_SECTION = A_COURSE_CODE_SECT
AND F.REPORT_PERIOD = A_REPORT_PERIOD;

IF C = 1 THEN
    SELECT * INTO R_SCA --LOAD LE RECORD
    FROM FS_SECONDARY_COURSE_ACHIEVE F
    WHERE
    F.PERSON_ID = A_PERSON_ID
    AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
    AND F.SCHOOL_CODE = A_SCHOOL_CODE         
    AND F.COURSE_CODE = A_COURSE_CODE
    AND F.COURSE_SECTION = A_COURSE_CODE_SECT
    AND F.REPORT_PERIOD = A_REPORT_PERIOD;

    CASE A_HH --ON STOCK LA COTE DU HH VOULU
        WHEN 'LS_FRENCH_SPEAKING' THEN
            V_COTE := R_SCA.LS_FRENCH_SPEAKING;                   
        WHEN 'LS_RESPONSIBILITY' THEN
            V_COTE := R_SCA.LS_RESPONSIBILITY;     
        WHEN 'LS_COLLABORATION' THEN
            V_COTE := R_SCA.LS_COLLABORATION; 
        WHEN 'LS_ORGANIZATION' THEN
            V_COTE := R_SCA.LS_ORGANIZATION;
        WHEN 'LS_WORK_INDEPENDENT' THEN
            V_COTE := R_SCA.LS_WORK_INDEPENDENT;
        WHEN 'LS_INITIATIVE' THEN
            V_COTE := R_SCA.LS_INITIATIVE;
        WHEN 'LS_SELF_REGULATION' THEN
            V_COTE := R_SCA.LS_SELF_REGULATION;
        ELSE  V_COTE := '!!';
    END CASE;
ELSIF C < 1 THEN --L'ÉLÈVE N'A PAS D'ENTRÉE DE RENDEMENT POUR CE COURS (AJOUTÉ LE 4 JUIN 2015)
    V_COTE := ' ';   
ELSE
    V_COTE := '!'; --L'ÉLÈVE A DEUX ENTRÉÉS DE RENDEMENT POUR LE M^ME COURS
END IF;

IF V_COTE = 'G' THEN -- G (Good) apparait au lieu de T (Très bien) Les trois autres cotes (N, S et E) coïncident dans les deux langues ....
V_COTE := 'T';
END IF;

RETURN V_COTE;

END GET_COTE_HH_SEC;

FUNCTION GET_COTE_HH_ELE(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2, A_HH VARCHAR2 ) RETURN VARCHAR2 IS  
--cette fonction retourne une COTE pour un hh avec les paramêtre si dessus
V_COTE VARCHAR2(50) :=NULL;
R_SA STUDENT_ACHIEVEMENT%ROWTYPE;
C NUMBER; 

V_YEAR VARCHAR2(3);
V_REPORT_PERIOD VARCHAR2(3);

BEGIN

--V_YEAR := CASE
--        WHEN To_Number(A_SCHOOL_YEAR) >= 20102011 THEN 'PIF'
--        ELSE '123'
--        END;
--        
--IF V_YEAR = '123' THEN
--    V_REPORT_PERIOD := CASE 
--    WHEN a_report_period = 'I' THEN '2'
--    WHEN a_report_period = 'F' THEN '3'
--    WHEN a_report_period = 'P' THEN '1'
--    END;
--ELSE 
--    V_REPORT_PERIOD := a_report_period;
--END IF;

SELECT COUNT(*) INTO C  --ON VEUX S'ASSURER QU'ON A SEULEMENT 1 RECORD
FROM STUDENT_ACHIEVEMENT F
WHERE
F.PERSON_ID = A_PERSON_ID
AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
AND F.SCHOOL_CODE = A_SCHOOL_CODE         
AND F.REPORT_PERIOD = a_report_period;

IF C = 1 THEN
    SELECT * INTO R_SA --LOAD LE RECORD
    FROM STUDENT_ACHIEVEMENT F
    WHERE
    F.PERSON_ID = A_PERSON_ID
    AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
    AND F.SCHOOL_CODE = A_SCHOOL_CODE         
    AND F.REPORT_PERIOD = a_report_period;

    CASE A_HH --ON STOCK LA COTE DU HH VOULU
        WHEN 'LS_USE_OF_ORAL_FRE' THEN
            V_COTE := R_SA.LS_USE_OF_ORAL_FRE;                   
        WHEN 'LS_RESPONSIBILITY' THEN
            V_COTE := R_SA.LS_RESPONSIBILITY;     
        WHEN 'LS_COLLABORATION' THEN
            V_COTE := R_SA.LS_COLLABORATION; 
        WHEN 'LS_ORGANIZATION' THEN
            V_COTE := R_SA.LS_ORGANIZATION;
        WHEN 'LS_INDEPENDENT_WORK' THEN
            V_COTE := R_SA.LS_INDEPENDENT_WORK;
        WHEN 'LS_INITIATIVE' THEN
            V_COTE := R_SA.LS_INITIATIVE;
        WHEN 'LS_SELF_REGULATION' THEN
            V_COTE := R_SA.LS_SELF_REGULATION;
        WHEN 'LS_HOMEWORK_COMPLETION' THEN 
            V_COTE := R_SA.LS_HOMEWORK_COMPLETION;
        WHEN 'LS_USE_OF_INFORMATION' THEN 
            V_COTE := R_SA.LS_USE_OF_INFORMATION;  
        WHEN 'LS_COOPERATION_WITH_OTHERS' THEN
            V_COTE := R_SA.LS_COOPERATION_WITH_OTHERS;
        WHEN 'LS_CLASS_PARTICIPATION' THEN
            V_COTE := R_SA.LS_CLASS_PARTICIPATION;
        WHEN 'LS_PROBLEM_SOLVING' THEN 
            V_COTE := R_SA.LS_PROBLEM_SOLVING;
        WHEN 'LS_GOAL_SETTING' THEN 
            V_COTE := R_SA.LS_GOAL_SETTING;
        ELSE  V_COTE := null;
    END CASE;  
    
CASE V_COTE
    WHEN 'E' THEN V_COTE := 'E';
    WHEN 'G' THEN V_COTE := 'T';
    WHEN 'S' THEN V_COTE := 'S';
    WHEN 'N' THEN V_COTE := 'N';
    ELSE V_COTE := NULL;
END CASE;      

ELSE
IF C > 1 THEN
    V_COTE := '!!'; --L'ÉLÈVE A DEUX ENTRÉÉS DE RENDEMENT POUR LE MÊME COURS 
END IF;
END IF;

IF v_cote = ' ' OR v_cote = ''  THEN v_cote := NULL;END IF;


RETURN V_COTE;

END GET_COTE_HH_ELE;

FUNCTION GET_START_DATE (A_PERSON_ID VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_SCHOOL_CODE VARCHAR2) RETURN DATE IS
/*****************************************************
*     Retourne la date de d'arrivé d'un élève.       *
*  Utilisé dans le query pour le rapport d'effectif  *
******************************************************/
START_DATE DATE := NULL;

BEGIN 

SELECT EFFECTIVE_DATE INTO START_DATE
FROM trill02.VW_MAX_ENROL_EFFDATE vw
WHERE A_PERSON_ID = VW.PERSON_ID
AND A_SCHOOL_YEAR = VW.SCHOOL_YEAR
AND A_SCHOOL_CODE = VW.SCHOOL_CODE
AND TRANSACTION_TYPE_IND = '4';

RETURN START_DATE;
END GET_START_DATE;

FUNCTION GET_DEPARTURE_DATE (A_PERSON_ID VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_SCHOOL_CODE VARCHAR2) RETURN DATE IS
/*****************************************************
*       Retourne la date de démit d'un élève.        *
*  Utilisé dans le query pour le rapport d'effectif  *
*****************************************************/
DEPARTURE_DATE DATE := NULL;

BEGIN 

SELECT EFFECTIVE_DATE INTO DEPARTURE_DATE
FROM trill02.VW_MAX_ENROL_EFFDATE vw
WHERE A_PERSON_ID = VW.PERSON_ID
AND A_SCHOOL_YEAR = VW.SCHOOL_YEAR
AND A_SCHOOL_CODE = VW.SCHOOL_CODE
AND TRANSACTION_TYPE_IND = '5';

RETURN DEPARTURE_DATE;
END GET_DEPARTURE_DATE;

FUNCTION GET_MOY_COMP_ELE(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2, A_SUBJECT_CODE VARCHAR2, A_COMP varchar2, A_STRAND_CODE VARCHAR2, A_GRADE VARCHAR2) RETURN VARCHAR2 IS
 --cette fonction calcule la moyenne d'une compétance pour toutes les évaluation d'un cours avec les paramêtres si dessus  
 /* Les moyennes de compétances son stocké dans SP_eleves_resultaTS ON DEVRAIT INCLURE LA CLASSE DE L'ÉLÈVE DASN LE PARAMÊTRE SI DESSUS*/
 R_RESULTATS SP_ELEVES_RESULTATS%ROWTYPE;
 V_COUNT NUMBER;
 V_MOYENNE VARCHAR2(10) := NULL;
 V_NIV_REND VARCHAR2(10) :=NULL;
 
 BEGIN
--CONTE LES RÉSULTATS 
 SELECT COUNT(*) INTO V_COUNT
  FROM SP_ELEVES_RESULTATS WHERE
 M_MEMBRE_ID = A_PERSON_ID AND
 M_ECOLE = A_SCHOOL_CODE AND
 M_ANNEESCOLAIRE = A_SCHOOL_YEAR AND
 M_PERIODE_REF = A_REPORT_PERIOD AND
 M_SUBJECT_CODE =  A_SUBJECT_CODE AND
 M_STRAND_CODE = A_STRAND_CODE
 AND M_A_QUITTE = 'N'; 
 --sI NOUS AVONS UN RECORD ENR/GISTRE LA MOYENNE DE LA COMP VOULUS
 IF V_COUNT = 1 THEN
  SELECT * INTO R_RESULTATS
  FROM SP_ELEVES_RESULTATS WHERE
 M_MEMBRE_ID = A_PERSON_ID AND
 M_ECOLE = A_SCHOOL_CODE AND
 M_ANNEESCOLAIRE = A_SCHOOL_YEAR AND
 M_PERIODE_REF = A_REPORT_PERIOD AND
 M_SUBJECT_CODE =  A_SUBJECT_CODE AND
 M_STRAND_CODE = A_STRAND_CODE  AND 
M_A_QUITTE = 'N';
 
 CASE A_COMP
    WHEN '1' THEN V_MOYENNE := R_RESULTATS.M_COMP1_MOYENNE;
    WHEN '2' THEN V_MOYENNE := R_RESULTATS.M_COMP2_MOYENNE;
    WHEN '3' THEN V_MOYENNE := R_RESULTATS.M_COMP3_MOYENNE;
    WHEN '4' THEN V_MOYENNE := R_RESULTATS.M_COMP4_MOYENNE;
    ELSE V_MOYENNE := NULL;
 END CASE;
 
 --SORTIR LE NIVEAU DU BAREM D'APRÈS LA MOYENNE
 IF V_MOYENNE is not null THEN
 IF A_GRADE IN ('07','08') THEN
  SELECT B_NIVEAU_RENDEMENT INTO  V_NIV_REND
        FROM SP_BAREMES 
        WHERE B_NIVEAU = 'S' AND 
        B_ANNEESCOLAIRE = A_SCHOOL_YEAR AND
        V_MOYENNE BETWEEN  B_NOTE_MIN AND B_NOTE_MAX;
 ELSE --01,02,03,04,05,06
   SELECT B_NIVEAU_RENDEMENT INTO  V_NIV_REND
        FROM SP_BAREMES 
        WHERE B_NIVEAU = 'E' AND 
        B_ANNEESCOLAIRE = A_SCHOOL_YEAR AND
        ROUND(V_MOYENNE) = B_NOTE_ATTRIBUEE;
 END IF;
 ELSE
 V_NIV_REND := NULL;
 END IF;
 
 ELSE
 --SI NOUS AVONS PLUS QU'UN RECORD ENREGISTRE !!! POUR LE MOMENT AU LIEU DE DEVINER QUELLE UTILISER
 IF V_COUNT > 1 THEN
V_NIV_REND := '!!';
 END IF;
 --SI NOUS AVONS PAS DE RÉSULTATS LA MOYENNE DEMEUR NULL
 V_NIV_REND := NULL;
 END IF;
 
 
 
 RETURN V_NIV_REND;

END GET_MOY_COMP_ELE;

FUNCTION GET_TERM_START_DATE(A_DATE varchar2, A_SCHOOL_CODE varchar2, A_SCHOOL_YEAR varchar2) RETURN DATE IS  
--cette fonction retourne LA DATE DE DÉBUT D'UN TERM DEMANDÉ

v_start date :=NULL;
--V_SEMESTER VARCHAR2(1) :=NULL;
--V_TERM VARCHAR2(1) := NULL;

BEGIN
                                              /***************************************************************************
--V_SEMESTER := SUBSTR(A_REPORT_PERIOD,1,1);  *   Les données dans la table sp_évaluations n'indiquent que rarement une  *
--                                            *   une période d'évaluation.. Donc, nous chercherons utilisant la donnée  *
--CASE SUBSTR(A_REPORT_PERIOD,2,1)            *   qui indique la date de prise pour une évalutation telquelle.           * 
--        WHEN 'M' THEN V_TERM := '1';        ***************************************************************************/
--        WHEN 'F' THEN V_TERM := '2';
--        ELSE V_TERM := NULL;
--END CASE;
                         
SELECT TERM_START into v_start
    FROM SCHOOL_TERMS 
    WHERE SCHOOL_YEAR = A_SCHOOL_YEAR
    AND SCHOOL_CODE = A_SCHOOL_CODE
    AND SCHOOL_YEAR_TRACK LIKE ('9%')
    AND A_DATE BETWEEN TERM_START AND TERM_END;
--    AND SEMESTER = V_SEMESTER
--    AND TERM = V_TERM;
    
RETURN V_START;
                         
END GET_TERM_START_DATE;

FUNCTION GET_TERM_END_DATE(A_DATE varchar2, A_SCHOOL_CODE varchar2, A_SCHOOL_YEAR varchar2 ) RETURN DATE IS  
--cette fonction retourne LA DATE DE FIN D'UN TERM DEMANDÉ

v_END date :=NULL;
--V_SEMESTER VARCHAR2(1) :=NULL;
--V_TERM VARCHAR2(1) := NULL;


BEGIN
                                              /***************************************************************************
--V_SEMESTER := SUBSTR(A_REPORT_PERIOD,1,1);  *   Les données dans la table sp_évaluations n'indiquent que rarement une  *
--                                            *   une période d'évaluation.. Donc, nous chercherons utilisant la donnée  *
--CASE SUBSTR(A_REPORT_PERIOD,2,1)            *   qui indique la date de prise pour une évalutation telquelle.           * 
--        WHEN 'M' THEN V_TERM := '1';        ***************************************************************************/
--        WHEN 'F' THEN V_TERM := '2';
--        ELSE V_TERM := NULL;
--END CASE;

SELECT TERM_END into v_end
    FROM SCHOOL_TERMS 
    WHERE SCHOOL_YEAR = A_SCHOOL_YEAR
    AND SCHOOL_CODE = A_SCHOOL_CODE
    AND SCHOOL_YEAR_TRACK LIKE ('9%')
    AND A_DATE BETWEEN TERM_START AND TERM_END;
--    AND SEMESTER = V_SEMESTER
--    AND TERM = V_TERM; 
    
   RETURN V_END;
                         
END GET_TERM_END_DATE;

FUNCTION GET_MOY_COMP_SEC(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2, A_COURSE_CODE VARCHAR2, A_CLASS_CODE VARCHAR2, A_COMP varchar2, A_STRAND_CODE VARCHAR2) RETURN NUMBER IS
 --cette fonction calcule la moyenne d'une compétance pour toutes les évaluation d'un cours avec les paramêtres si dessus
 v_total_ponderations NUMBER := 0;
 v_total_ponderations_examen NUMBER := 0;
 v_note_semestre NUMBER := 0;
 v_note_exam NUMBER := 0;
 v_note NUMBER := 0;
 v_pourcentage_examen NUMBER := 0;
 v_pourcentage_semestre NUMBER := 0;
 v_m_examen_existe varchar2(1) := 'N';
 v_term_start date;
 v_term_end date;
 
--la liste d'évaluation POUR UN ÉLÈVE
CURSOR c_les_evaluations IS
SELECT * 
FROM sp_evaluations, sp_notes
WHERE e_anneescolaire = A_SCHOOL_YEAR AND
e_ecole       = A_SCHOOL_CODE AND
e_classe_code   = A_CLASS_CODE AND
e_codecours     = A_COURSE_CODE AND
e_periode_ref   = '00' AND
e_strand_code   = A_STRAND_CODE AND
pkg_sp.fc_evaluation_comptabilisee(e_evaluation_id) = 'O' AND--l'évaluation doit être complète
e_evaluation_id = n_evaluation_id AND
n_membre_id    = A_PERSON_ID AND
n_abs = 'N' AND
E_DATE 
BETWEEN 
GET_TERM_START_DATE(E_DATE, E_ECOLE, E_ANNEESCOLAIRE)
AND
GET_TERM_END_DATE(E_DATE, E_ECOLE, E_ANNEESCOLAIRE); --TIRE SEULEMENT LES ÉVALUATION DATÉ ENTRE LES DATE DE DÉBUT ET DATE DE FIN DU TERM

    
    R_EVALUATION C_LES_EVALUATIONS%ROWTYPE;        
        
    BEGIN      
   -- trouver le pourcentage de l'examen et du semestre
  SELECT p_pourcentage_examen, p_pourcentage_semestre INTO v_pourcentage_examen, v_pourcentage_semestre
  FROM sp_pourcentage
  WHERE  p_anneescolaire = A_SCHOOL_YEAR;
      
--traiter chaque évaluations pour calculer la note de la compétence 
FOR R_EVALUATION IN C_LES_EVALUATIONS    
 LOOP        
           CASE A_COMP--check pour quelle compétance
               when 1 then--CC
                     IF R_EVALUATION.E_EXAMEN = 'N' THEN  --évaluations régulier ;                        
                          if R_EVALUATION.E_COMP1_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP1_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE  --l'examen                            
                          if R_EVALUATION.E_COMP1_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP1_SUR100 * R_EVALUATION.E_PONDERATION); --On évalue la note sur 100 pour éviter de reçevoir des données imprécises   
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION;              --(pour les gabarits qui évaluentsur une base autre que 100)
                          end if;       
                    END IF;                  
               when 2 then--HP
                     IF R_EVALUATION.E_EXAMEN = 'N' THEN--évaluations régulier ;                         
                          if R_EVALUATION.E_COMP2_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP2_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE      --l'examen                             
                          if R_EVALUATION.E_COMP2_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP2_SUR100 * R_EVALUATION.E_PONDERATION);
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION; 
                          end if;       
                    END IF;                  
               when 3 then--COM
                      IF R_EVALUATION.E_EXAMEN = 'N' THEN  --évaluations régulier ;                           
                          if R_EVALUATION.E_COMP3_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP3_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE     --l'examen                              
                          if R_EVALUATION.E_COMP3_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP3_SUR100 * R_EVALUATION.E_PONDERATION);
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION; 
                          end if;       
                    END IF;                  
               when 4 then--MA
                    IF R_EVALUATION.E_EXAMEN = 'N' THEN   --évaluations régulier ;                       
                          if R_EVALUATION.E_COMP4_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP4_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE      --l'examen                        
                          if R_EVALUATION.E_COMP4_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP4_SUR100 * R_EVALUATION.E_PONDERATION);
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION; 
                          end if;       
                    END IF;       
                else 
                    v_note_exam := null;
                    v_note_semestre := null;
                               
           end case;
            
 END LOOP;    
 
 --calcule final pour la note des évaluation reg
    IF v_total_ponderations > 0 THEN
      v_note_semestre := v_note_semestre / v_total_ponderations;
     ELSE
      v_note_semestre := NULL;
    END if;

 --calcule final pour la note des évaluation exam
     IF v_total_ponderations_examen > 0 THEN
      v_note_exam   := v_note_exam   / v_total_ponderations_examen;
     ELSE
      v_note_exam   := NULL;
     END IF;

      IF v_note_semestre IS NOT NULL AND v_note_exam IS NOT NULL THEN
       /* Calculer la note finale à partir de la note du semestre et de la note d'examen */
     v_note := (v_note_semestre * (v_pourcentage_semestre / 100)) + (v_note_exam * (v_pourcentage_examen / 100));
     ELSIF v_note_semestre > 0 THEN
        /* Seulement la note du semestre */
        v_note :=  v_note_semestre;
     ELSE

        /* Seulement la note de l'examen s'il n'y a pas de note du semestre */
        v_note := v_note_exam;
     END if;
     
        return ROUND(v_note,1);
       /*si on voudrais la note attribué du barème on utiliserais cette requ^te*/
--      SELECT B_NOTE_ATTRIBUEE INTO v_note FROM SP_BAREMES
--      WHERE B_ANNEESCOLAIRE = p_anneescolaire
--        AND B_NIVEAU = v_palier
--        AND p_note BETWEEN B_NOTE_MIN AND B_NOTE_MAX;

END GET_MOY_COMP_SEC;

FUNCTION GET_RAPPORT_P(A_P_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_SUBJECT_CODE VARCHAR2) RETURN VARCHAR2 IS

    COTE_P VARCHAR2(20) := NULL;
    COUNT_ROWS NUMBER := 0;

BEGIN 

SELECT COUNT(*) INTO COUNT_ROWS 

FROM STUDENT_COURSE_STRAND_ACHIEVE SCSA, COURSE_CODES CC, SUBJECTS S

WHERE SCSA.PERSON_ID =  A_P_ID 

AND SCSA.SCHOOL_CODE = A_SCHOOL_CODE
AND SCSA.SCHOOL_CODE = CC.SCHOOL_CODE

AND SCSA.SCHOOL_YEAR = A_SCHOOL_YEAR 
AND SCSA.SCHOOL_YEAR = CC.SCHOOL_YEAR

AND SCSA.STRAND_CODE = '999'
AND SCSA.COURSE_CODE = CC.COURSE_CODE
AND SCSA.GRADE = CC.GRADE
AND CC.SUBJECT_CODE = S.SUBJECT_CODE
AND S.SUBJECT_CODE = A_SUBJECT_CODE;

IF( COUNT_ROWS = 1 ) THEN 

    SELECT TO_CHAR(SCSA.MARK) INTO COTE_P
           
    FROM STUDENT_COURSE_STRAND_ACHIEVE SCSA, COURSE_CODES CC, SUBJECTS S

    WHERE SCSA.PERSON_ID =  A_P_ID 

    AND SCSA.SCHOOL_CODE = A_SCHOOL_CODE
    AND SCSA.SCHOOL_CODE = CC.SCHOOL_CODE

    AND SCSA.SCHOOL_YEAR = A_SCHOOL_YEAR 
    AND SCSA.SCHOOL_YEAR = CC.SCHOOL_YEAR

    AND SCSA.STRAND_CODE = '999'
    AND SCSA.COURSE_CODE = CC.COURSE_CODE
    AND SCSA.GRADE = CC.GRADE
    AND CC.SUBJECT_CODE = S.SUBJECT_CODE
    AND S.SUBJECT_CODE = A_SUBJECT_CODE;

ELSE 
    COTE_P := '!';

END IF;

RETURN COTE_P;
END GET_RAPPORT_P;

FUNCTION GET_EARNED_CREDIT(A_P_ID VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REQ_AREA VARCHAR2) RETURN NUMBER IS
CREDIT_EARNED NUMBER := NULL;

BEGIN

select sum(earned_credit_value) INTO CREDIT_EARNED
from FS_SECONDARY_COURSE_CREDIT 
where requirement_area = A_REQ_AREA 
and person_id = A_P_ID 
and school_year= A_SCHOOL_YEAR;

RETURN CREDIT_EARNED;
END GET_EARNED_CREDIT;

FUNCTION GET_YTD_ABS(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2) RETURN number as
v_abs number :=0;
begin
/*if PI_GRADE >= 09 then 
    select sum(count(*)/gcc) into v_abs
from 
(
select PKG_PROFILE_ÉLÈVE.GET_COURSE_COUNT(PKG_PROFILE_ÉLÈVE.GET_SCHOOL_YEAR(sysdate),  PI_PERSON_ID,  --Cette fonction retourne le nombre de cours dans lequel
             (case when (pa.CALENDAR_DATE BETWEEN--     un élève est inscrit qui doit prendre l'assiduité.
                         SS.SEMESTER_START AND  --Ce Case statement détermine, d'après la date de l'absence, 
                         SS.SEMESTER_END)       --     le semestre courrant.
                   then SS.SEMESTER
             end)) as gcc
                   
                   
                    from period_attendance pa, SCHOOL_SEMESTERS SS WHERE 
pa.person_ID = PI_PERSON_ID 
AND pa.School_year = PI_SCHOOL_YEAR 
AND pa.calendar_date <= PI_DATE
AND SS.SCHOOL_CODE = pa.SCHOOL_CODE
AND SS.SCHOOL_YEAR = pa.SCHOOL_YEAR
AND PA.SCHOOL_CODE IN ('ESF', 'ESA', 'ESE')
AND CLASS_CODE IS NOT NULL
and attendance_code <> 'L'
AND PA.SCHOOL_YEAR_TRACK = SS.SCHOOL_YEAR_TRACK
AND CALENDAR_DATE BETWEEN SS.SEMESTER_START AND SS.SEMESTER_END
)
group by gcc;

elsif PI_GRADE < 9 then 
select           
sum(SUM(CASE WHEN  SCHOOL_CODE NOT IN ('CDJ', 'EJE') 
                    THEN 1/2                  --ÉCOLES ÉLÉMENTAIRES QUI NE SONT PAS CDJ PRENNENT LES ABSENCES À CHAQUE (2) PÉRIODE
                    
                    WHEN  SCHOOL_CODE IN ('CDJ') 
                    AND CALENDAR_DATE < TO_DATE('30/06/2012', 'DD/MM/YYYY') 
                    THEN 1/2                  --AVANT LE CHANGEMENT DES PÉRIODE À CDJ, EN 2012, CDJ PRENNAIT LES ABSENCES À CHAQUE (2) PÉRIODE 
                    
                    WHEN SCHOOL_CODE IN ('CDJ')
                    AND CALENDAR_DATE > TO_DATE('30/06/2012', 'DD/MM/YYYY') 
                    THEN ROUND(1/6, 2)      --APRÈS LE CHANGEMENT DES PÉRIODES À CDJ, EN 2012, CDJ PRENNENT MAINTENT L'ABSENCE À CHAQUE (6) PÉRIODE
                    
                    WHEN SCHOOL_CODE IN ('EJE')
                    AND CALENDAR_DATE BETWEEN TO_DATE('01/09/2004', 'DD/MM/YYYY') AND TO_DATE('30/06/2005', 'DD/MM/YYYY')
                    THEN 1/2
                    
                    WHEN SCHOOL_CODE IN ('EJE')
                    AND CALENDAR_DATE BETWEEN TO_DATE('01/09/2005', 'DD/MM/YYYY') AND TO_DATE('30/06/2006', 'DD/MM/YYYY')
                    THEN 1/4
                    
                    WHEN SCHOOL_CODE IN ('EJE')
                    AND CALENDAR_DATE BETWEEN TO_DATE('01/09/2006', 'DD/MM/YYYY') AND TO_DATE('30/06/2007', 'DD/MM/YYYY')
                    THEN ROUND(1/5, 2)
                    
                    WHEN SCHOOL_CODE IN ('EJE')
                    AND CALENDAR_DATE BETWEEN TO_DATE('01/09/2007', 'DD/MM/YYYY') AND TO_DATE('30/06/2009', 'DD/MM/YYYY')
                    THEN ROUND(1/6, 2)
                    
                    WHEN SCHOOL_CODE IN ('EJE')
                    AND CALENDAR_DATE BETWEEN TO_DATE('01/09/2009', 'DD/MM/YYYY') AND TO_DATE('30/06/2010', 'DD/MM/YYYY')
                    THEN 1/2
           END)) into v_abs

             
from 
(select  SCHOOL_CODE, calendar_date

    
           
FROM PERIOD_ATTENDANCE

WHERE PERSON_ID =  PI_PERSON_ID 

AND SCHOOL_CODE NOT IN ('ESF', 'ESA', 'ESE')
AND ATTENDANCE_CODE IN ('A', 'N', 'E', 'G') 
AND UPPER(SCHOOL_PERIOD) NOT IN ('DÎNER', 'DINER', 'ACCEUIL', 'ACC.') --On ne compte pas les absences prises durant le dîner, ou pendant l'acceuil/foyer
and school_year = PI_SCHOOL_YEAR
AND calendar_date <= PI_DATE
)
group by calendar_date;
end if; */

SELECT MAX(F.YTD_ABSENCES) INTO v_ABS
FROM STUDENT_ACHIEVEMENT F
WHERE
F.PERSON_ID = A_PERSON_ID
AND F.SCHOOL_YEAR = A_SCHOOL_YEAR    
AND F.SCHOOL_CODE = A_SCHOOL_CODE;

return v_abs;

end GET_YTD_ABS;

FUNCTION GET_YTD_LATES(PI_PERSON_ID VARCHAR2, PI_SCHOOL_YEAR VARCHAR2, PI_DATE date) RETURN VARCHAR2 as
v_lates number :=0;
begin
select COUNT(*) into v_lates from period_attendance WHERE 
period_attendance.person_ID = PI_PERSON_ID AND 
period_attendance.School_year = PI_SCHOOL_YEAR AND attendance_code = 'L' AND 
period_attendance.calendar_date <= PI_DATE;
return v_lates;
end GET_YTD_LATES;

FUNCTION GET_PERIOD_START(A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2) RETURN DATE AS 
START_DATE DATE := NULL;

BEGIN 
SELECT START_DATE INTO START_DATE 
FROM ACHIEVEMENT_REPORT_PERIODS
WHERE SCHOOL_YEAR = A_SCHOOL_YEAR
AND SCHOOL_CODE = A_SCHOOL_CODE
AND REPORT_PERIOD = A_REPORT_PERIOD;

RETURN START_DATE;
END GET_PERIOD_START; 

FUNCTION GET_PERIOD_END(A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_REPORT_PERIOD VARCHAR2) RETURN DATE AS 
END_DATE DATE := NULL;

BEGIN 
SELECT END_DATE INTO END_DATE 
FROM ACHIEVEMENT_REPORT_PERIODS
WHERE SCHOOL_YEAR = A_SCHOOL_YEAR
AND SCHOOL_CODE = A_SCHOOL_CODE
AND REPORT_PERIOD = A_REPORT_PERIOD;

RETURN END_DATE;
END GET_PERIOD_END; 

FUNCTION GET_MOY_COMP_ELE_P(A_PERSON_ID VARCHAR2, A_SCHOOL_CODE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_SUBJECT_CODE VARCHAR2, A_COMP VARCHAR2) RETURN VARCHAR2 IS
 --cette fonction calcule la moyenne d'une compétance pour toutes les évaluation d'un cours avec les paramêtres si dessus
 v_total_ponderations NUMBER := 0;
 v_total_ponderations_examen NUMBER := 0;
 v_note_semestre NUMBER := 0;
 v_note_exam NUMBER := 0;
 v_note NUMBER := 0;
 v_pourcentage_examen NUMBER := 0;
 v_pourcentage_semestre NUMBER := 0;
 v_m_examen_existe varchar2(1) := 'N';
 NOTE_BARÊME VARCHAR2(5) := NULL;
 
--la liste d'évaluation POUR UN ÉLÈVE
CURSOR c_les_evaluations IS
SELECT * 
FROM sp_evaluations, sp_notes
WHERE e_anneescolaire = A_SCHOOL_YEAR AND
e_ecole       = A_SCHOOL_CODE AND
e_SUBJECT_code   = A_SUBJECT_CODE AND
e_periode_ref   = 'I' AND
pkg_sp.fc_evaluation_comptabilisee(e_evaluation_id) = 'O' AND--l'évaluation doit être complète
e_evaluation_id = n_evaluation_id AND
n_membre_id    = A_PERSON_ID AND
n_abs = 'N' AND
E_DATE 
BETWEEN 
GET_PERIOD_START(E_ECOLE, E_ANNEESCOLAIRE, 'P')
AND
GET_PERIOD_END(E_ECOLE, E_ANNEESCOLAIRE, 'P'); --TIRE SEULEMENT LES ÉVALUATION DATÉ ENTRE LES DATE DE DÉBUT ET DATE DE FIN DE LA PÉRIODE DE RAPPORT P

    
    R_EVALUATION C_LES_EVALUATIONS%ROWTYPE;        
        
    BEGIN      
   -- trouver le pourcentage de l'examen et du semestre
  SELECT p_pourcentage_examen, p_pourcentage_semestre INTO v_pourcentage_examen, v_pourcentage_semestre
  FROM sp_pourcentage
  WHERE  p_anneescolaire = A_SCHOOL_YEAR;
      
--traiter chaque évaluations pour calculer la note de la compétence 
FOR R_EVALUATION IN C_LES_EVALUATIONS    
 LOOP        
           CASE A_COMP--check pour quelle compétance
               when 1 then--CC
                     IF R_EVALUATION.E_EXAMEN = 'N' THEN  --évaluations régulière ;                        
                          if R_EVALUATION.E_COMP1_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP1_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE  --l'examen                            
                          if R_EVALUATION.E_COMP1_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP1_SUR100 * R_EVALUATION.E_PONDERATION); --On évalue la note sur 100 pour éviter de reçevoir des données imprécises   
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION;              --(pour les gabarits qui évaluentsur une base autre que 100)
                          end if;       
                    END IF;                  
               when 2 then--HP
                     IF R_EVALUATION.E_EXAMEN = 'N' THEN--évaluations régulière ;                         
                          if R_EVALUATION.E_COMP2_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP2_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE      --l'examen                             
                          if R_EVALUATION.E_COMP2_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP2_SUR100 * R_EVALUATION.E_PONDERATION);
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION; 
                          end if;       
                    END IF;                  
               when 3 then--COM
                      IF R_EVALUATION.E_EXAMEN = 'N' THEN  --évaluations régulière ;                           
                          if R_EVALUATION.E_COMP3_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP3_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE     --l'examen                              
                          if R_EVALUATION.E_COMP3_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP3_SUR100 * R_EVALUATION.E_PONDERATION);
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION; 
                          end if;       
                    END IF;                  
               when 4 then--MA
                    IF R_EVALUATION.E_EXAMEN = 'N' THEN   --évaluations régulière ;                       
                          if R_EVALUATION.E_COMP4_UTILISATION = 'O' then
                            v_note_semestre := v_note_semestre + (R_EVALUATION.N_COMP4_SUR100 * R_EVALUATION.E_PONDERATION);
                            v_total_ponderations :=  v_total_ponderations + R_EVALUATION.E_PONDERATION;
                          end if;                          
                    ELSE      --l'examen                        
                          if R_EVALUATION.E_COMP4_UTILISATION = 'O' then
                          v_note_exam :=  v_note_exam + (R_EVALUATION.N_COMP4_SUR100 * R_EVALUATION.E_PONDERATION);
                          v_total_ponderations_examen := v_total_ponderations_examen + R_EVALUATION.E_PONDERATION; 
                          end if;       
                    END IF;       
                else 
                    v_note_exam := null;
                    v_note_semestre := null;
                               
           end case;
            
 END LOOP;    
 
 --calcule final pour la note des évaluation reg
    IF v_total_ponderations > 0 THEN
      v_note_semestre := v_note_semestre / v_total_ponderations;
     ELSE
      v_note_semestre := NULL;
    END if;

 --calcule final pour la note des évaluation exam
     IF v_total_ponderations_examen > 0 THEN
      v_note_exam   := v_note_exam   / v_total_ponderations_examen;
     ELSE
      v_note_exam   := NULL;
     END IF;

      IF v_note_semestre IS NOT NULL AND v_note_exam IS NOT NULL THEN
       /* Calculer la note finale à partir de la note du semestre et de la note d'examen */
     v_note := (v_note_semestre * (v_pourcentage_semestre / 100)) + (v_note_exam * (v_pourcentage_examen / 100));
     ELSIF v_note_semestre > 0 THEN
        /* Seulement la note du semestre */
        v_note :=  v_note_semestre;
     ELSE

        /* Seulement la note de l'examen s'il n'y a pas de note du semestre */
        v_note := v_note_exam;
     END if;
     
       
       /*Conversion de la Note_attribuée vers un cote de cours style '1, 2, 3, 4'*/
      SELECT B_NIVEAU_RENDEMENT INTO  NOTE_BARÊME FROM SP_BAREMES
      WHERE B_ANNEESCOLAIRE = a_school_year
        AND B_NIVEAU = 'E'
        AND v_note = B_NOTE_ATTRIBUEE;
        
         return  NOTE_BARÊME;

END GET_MOY_COMP_ELE_P;

FUNCTION GET_NOTE_RENDEMENT(A_NOTE VARCHAR2, A_SCHOOL_YEAR VARCHAR2, A_GRADE VARCHAR2) RETURN VARCHAR2 IS
NOTE VARCHAR2(4) := NULL;
NIVEAU VARCHAR(3) := NULL;

BEGIN 

IF(A_GRADE < 07) THEN NIVEAU := 'E';

SELECT B_NIVEAU_RENDEMENT INTO NOTE FROM SP_BAREMES
      WHERE B_ANNEESCOLAIRE = A_SCHOOL_YEAR
        AND B_NIVEAU = NIVEAU
        AND A_NOTE = B_NOTE_ATTRIBUEE;

ELSIF(A_GRADE IN (07, 08)) THEN  NOTE := A_NOTE;

END IF;

RETURN NOTE;
END GET_NOTE_RENDEMENT;

FUNCTION GET_PNMI(A_PID VARCHAR2) RETURN VARCHAR2 IS
STATUT VARCHAR2(70) := NULL;
N_ID VARCHAR(1) := NULL;
ROW_COUNT NUMBER := NULL;

BEGIN 
select count(*) INTO ROW_COUNT
from FS_NATIVE_IDENTIFICATION, persons 
where person_id = A_PID
and native_flag = native_id;

IF(ROW_COUNT < 1) THEN 
    STATUT := 'Non';
    
ELSE 
    select FULL_NAME_F, NATIVE_ID INTO STATUT, N_ID
    from FS_NATIVE_IDENTIFICATION, persons 
    where person_id = A_PID
    and native_flag = native_id;
END IF;

IF STATUT = 'Premières Nations' THEN
    STATUT := 'PN';
ELSIF STATUT = 'Inuit' THEN 
    STATUT := 'I';
ELSIF STATUT = 'Métis' THEN
    STATUT := 'M';
ELSIF STATUT IN ('Élève autochtone demeurant sur la réserve', 'Élève non-autochtone deumeurant sur une réserve', 'Élève autochtone demeurant hors de la réserve', 'Identifié soi-même') THEN
    STATUT := 'ATT';
END IF;

RETURN STATUT;
END GET_PNMI;

FUNCTION GET_MATERNAL_LANG(P_ID VARCHAR2) RETURN VARCHAR2 IS 

ROW_COUNT NUMBER := NULL;
MAT_LANG VARCHAR2(25) := NULL;

BEGIN 
SELECT COUNT(*) INTO ROW_COUNT
    FROM person_languages pl, languages l 
    where mother_tongue_flag = 'x'
    and l.language_name = pl.language_name
    and person_id = P_ID;
    
IF (ROW_COUNT > 0) THEN 
    SELECT language_name_f INTO MAT_LANG
    FROM person_languages pl, languages l 
    where mother_tongue_flag = 'x'
    and l.language_name = pl.language_name
    and person_id = P_ID;
ELSE 
    MAT_LANG := NULL;
END IF;
    
RETURN MAT_LANG;
END GET_MATERNAL_LANG;


FUNCTION GET_SPOKEN_AT_HOME(P_ID VARCHAR2) RETURN VARCHAR2 IS 

ROW_COUNT NUMBER := NULL;
LANG VARCHAR2(25) := NULL;

BEGIN 
SELECT COUNT(*) INTO ROW_COUNT
    FROM person_languages pl, languages l 
    where spoken_at_home_flag = 'x'
    and l.language_name = pl.language_name
    and person_id = P_ID;
    
IF (ROW_COUNT > 0) THEN 
    SELECT 
    case 
        when language_name_f = 'Anglais & França' 
        then 'Anglais et Français' 
        else language_name_f
        end
    INTO LANG
    FROM person_languages pl, languages l 
    where spoken_at_home_flag = 'x'
    and MAIN_HOME_LANG_FLAG_10 = 1
    and l.language_name = pl.language_name
    and person_id = P_ID;
ELSE 
    LANG := 'N/A';
END IF;
    
RETURN LANG;
END GET_SPOKEN_AT_HOME;

FUNCTION GET_ADDRESS(P_ID VARCHAR2) RETURN VARCHAR2 IS

ADDRESS VARCHAR2(80) := NULL;
ROW_COUNT NUMBER := NULL;

BEGIN
SELECT COUNT(*) INTO ROW_COUNT 
FROM ADDRESSES A, PERSON_ADDRESSES PA
WHERE A.ADDRESS_ID = PA.ADDRESS_ID
AND PA.PERSON_ID = P_ID
AND SYSDATE BETWEEN PA.START_DATE AND NVL(PA.END_DATE, SYSDATE+1)
and address_type_name = 'Home';

IF (ROW_COUNT = 1) THEN

    SELECT STREET_NO || ' ' || STREET || chr(10) || JURISDICTION_NAME || ', ' || PROVINCE_STATE_CODE || chr(10) || POSTAL_CODE INTO ADDRESS
    FROM ADDRESSES A, PERSON_ADDRESSES PA
    WHERE A.ADDRESS_ID = PA.ADDRESS_ID
    AND PA.PERSON_ID = P_ID
    AND SYSDATE BETWEEN PA.START_DATE AND NVL(PA.END_DATE, SYSDATE+1)
    and address_type_name = 'Home';
    
ELSIF (ROW_COUNT > 1) THEN
    SELECT '!! - ' || STREET_NO || ' ' || STREET || chr(10) || JURISDICTION_NAME || ', ' || PROVINCE_STATE_CODE || chr(10) || POSTAL_CODE INTO ADDRESS
    FROM ADDRESSES A, PERSON_ADDRESSES PA
    WHERE A.ADDRESS_ID = PA.ADDRESS_ID
    AND PA.PERSON_ID = P_ID
    AND SYSDATE BETWEEN PA.START_DATE AND NVL(PA.END_DATE, SYSDATE+1)
    AND PA.START_DATE = (SELECT MAX(START_DATE) FROM PERSON_ADDRESSES PA
                         WHERE PA.PERSON_ID = P_ID
                         AND SYSDATE BETWEEN PA.START_DATE AND NVL(PA.END_DATE, SYSDATE+1) 
                         and address_type_name = 'Home')
    and address_type_name = 'Home';


ELSE 
    
    ADDRESS := NULL;

END IF;

RETURN ADDRESS;
END GET_ADDRESS;

FUNCTION OQRE_GET_COTE_RWM(A_GRADE VARCHAR2, A_MATIERE VARCHAR2, A_PERSON_ID VARCHAR2) RETURN VARCHAR2 IS
/*************************************************************************************
 * Le code pour la matière est comme suit:                                 20/01/16  *
 *   - 'R' afin de puiser la colonne ROVERALLLEVEL et ressortir la cote en LECTURE   *
 *   - 'W' afin de puiser la colonne WOVERALLLEVEL et ressortir la cote en ÉCRITURE  *
 *   - 'M' afin de puiser la colonne MOVERALLLEVEL er ressortir la cote en MATHS     *
 ************************************************************************************/

O_COTE VARCHAR2(30) := null;
V_OEN VARCHAR(64) := null;

BEGIN

select DISTINCT studentoen into v_oen
from oqre_3_6 oqre, persons p
WHERE P.PERSON_ID = A_PERSON_ID
  AND p.oen_number = oqre.studentoen
  and oqre.grade = a_grade;

SELECT CASE WHEN lower(A_MATIERE) = 'r' THEN ROVERALLLEVEL
            WHEN lower(A_MATIERE) = 'w' THEN WOVERALLLEVEL
            WHEN lower(A_MATIERE) = 'm' THEN MOVERALLLEVEL
            ELSE 'CODE INVALIDE'
       END AS COTE_OQRE INTO O_COTE

FROM oqre_3_6 oqre, PERSONS P

WHERE P.PERSON_ID = A_PERSON_ID
  AND p.oen_number = oqre.studentoen
  and oqre.grade = a_grade
  and oqre.school_year = (select max(school_year) 
                            from oqre_3_6 
                            where oqre_3_6.STUDENTOEN = V_OEN 
                            and oqre_3_6.grade = a_grade);

RETURN O_COTE;
END OQRE_GET_COTE_RWM;


FUNCTION OQRE_GET_COTE_TPCM(A_PERSON_ID VARCHAR2) RETURN VARCHAR2 IS
 /************
 * 20/01/16 *
 ************/
O_COTE VARCHAR2(15) := NULL;
V_OEN VARCHAR(25) := NULL;

BEGIN

select DISTINCT studentoen into v_oen
from oqre_9 oqre, persons p
WHERE P.PERSON_ID = A_PERSON_ID
  AND p.oen_number = oqre.studentoen;

SELECT overalloutcomelevel INTO O_COTE

FROM oqre_9 oqre, PERSONS P

WHERE P.PERSON_ID = A_PERSON_ID
  AND p.oen_number = oqre.studentoen
  and oqre.school_year = (select max(school_year) from oqre_9 where oqre_9.STUDENTOEN = V_OEN);

RETURN O_COTE;
END OQRE_GET_COTE_TPCM;

FUNCTION OQRE_GET_COTE_TPCL(A_PERSON_ID VARCHAR2) RETURN VARCHAR2 IS
 /************
 * 20/01/16 *
 ************/
O_COTE VARCHAR2(15) := NULL;
V_OEN VARCHAR(25) := NULL;

BEGIN

select DISTINCT studentoen into v_oen
from oqre_10 oqre, persons p
WHERE P.PERSON_ID = A_PERSON_ID
  AND p.oen_number = oqre.studentoen;

SELECT OSSLTOUTCOME INTO O_COTE

FROM oqre_10 oqre, PERSONS P

WHERE P.PERSON_ID = A_PERSON_ID
  AND p.oen_number = oqre.studentoen
  and oqre.school_year = (select max(school_year) from oqre_10 where oqre_10.STUDENTOEN = V_OEN);

RETURN O_COTE;
END OQRE_GET_COTE_TPCL;

END PKG_PROFILE_ÉLÈVE;
/