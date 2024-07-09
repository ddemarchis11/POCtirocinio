CREATE OR REPLACE TABLE marketing_prep.JourneyPrep
as
SELECT
j.*,
ja.id as activity_id,
ja.Activity_Name
FROM marketing_raw.journey j
INNER JOIN marketing_raw.journeyActivity ja on j.id = ja.JourneyID
where j.JourneyStatus='Running';

CREATE OR REPLACE TABLE marketing_prep.notifiche
as
select 
p.*,
"SUCC_NO_CLICK" as the_type
from marketing_source.notifiche p
LEFT OUTER JOIN marketing_source.notificheclick nc on cast(p.deviceID AS STRING) = CAST(nc.deviceID AS STRING) and CAST(p.id AS STRING) = CAST(nc.notificaID  AS STRING)
where upper(p.status) = upper("success")
and nc.deviceID is null 

UNION ALL

select 
p.*,
"SUCC_CLICK" as the_type

from marketing_source.notifiche p
INNER JOIN marketing_source.notificheclick pc on CAST(p.deviceID AS STRING) = CAST(pc.deviceID AS STRING) and CAST(p.id AS STRING) = cast(pc.notificaID AS STRING)
where upper(p.status) = upper("success");

CREATE OR REPLACE TABLE marketing_prep.notifiche
as
select
sl.*,
FORMAT_DATETIME(
  "%m/%d/%Y %H:%M:%S",
DATETIME(TIMESTAMP(PARSE_DATETIME("%m/%d/%Y %H:%M:%S", sl.DateTimeSend),
'America/Chicago'), 'Europe/Rome'))
as ymd_hms_DateTimeSend,
from marketing_prep.notifiche sl
where length(cast(sl.DateTimeSend as string)) <= 19;

CREATE OR REPLACE TABLE marketing_prep.sms
as
select
s.*,
FORMAT_DATETIME(
  "%Y-%m-%d %H:%M:%S",
DATETIME(TIMESTAMP(PARSE_DATETIME("%Y-%m-%d %H:%M:%S", s.logDate),
'America/Chicago'), 'Europe/Rome'))
as ymd_hms_logDate,
from marketing_prep.sms s
where length(cast(s.logDate as string)) <= 19;


-- Qui sdoppiamo le delivered e undelivered
CREATE OR REPLACE TABLE marketing_prep.sms
as
select 
*,
from marketing_source.sms p
where delivered=1
union all
select 
*,
from marketing_source.sms p
where undelivered=1;

CREATE OR REPLACE TABLE marketing_prep.emailunsub_prep
as
select
e.*,
FORMAT_DATETIME(
  "%m/%d/%Y %H:%M:%S",
DATETIME(TIMESTAMP(PARSE_DATETIME("%m/%d/%Y %H:%M:%S", e.EventDate),
'America/Chicago'), 'Europe/Rome'))
as ymd_hms_EventDate,
from marketing_source.emailunsub as e
where length(cast(e.EventDate as string)) <= 19;

CREATE OR REPLACE TABLE marketing_prep.emailinvii_prep
as
select
e.*,
FORMAT_DATETIME(
  "%m/%d/%Y %H:%M:%S",
DATETIME(TIMESTAMP(PARSE_DATETIME("%m/%d/%Y %H:%M:%S", e.EventDate),
'America/Chicago'), 'Europe/Rome'))
as ymd_hms_EventDate,
from marketing_source.emailinvii as e
where length(cast(e.EventDate as string)) <= 19;

CREATE OR REPLACE TABLE marketing_prep.emailclick_prep
as
select
e.*,
FORMAT_DATETIME(
  "%m/%d/%Y %H:%M:%S",
DATETIME(TIMESTAMP(PARSE_DATETIME("%m/%d/%Y %H:%M:%S", e.EventDate),
'America/Chicago'), 'Europe/Rome'))
as ymd_hms_EventDate,
from marketing_source.emailclick as e
where length(cast(e.EventDate as string)) <= 19;