CREATE OR REPLACE TABLE marketing_final.esitisms AS
select
c.cod_istituto as COD_ABI, -- codice istituto bancario
c.COD_NDG_ANAGRAFICA_NSG as COD_NDG, -- codice anagrafica
c.COD_FISCALE_PARTITA_IVA as COD_FISCALE,
c.EMAIL_ADDRESS as EMAIL,
jp.Activity_Name as ACTIVITY_NAME,
s.ymd_hms_logDate  as DATA_INVIO,
m.MICROESITO as COD_MICROESITO,
"SMS" as COD_CANALE
from marketing_prep.sms s
INNER JOIN marketing_raw.cliente c on s.SubscriberKey = c.SubscriberKey
INNER JOIN marketing_prep.JourneyPrep jp  on s.activity_id = jp.activity_id
INNER JOIN marketing_raw.microesiti m 
        on case
            when s.Undelivered = 1 THEN 'SMS_Undelivered'
            when s.Delivered = 1 THEN 'SMS_Delivered'
            ELSE 'SKIPPARE'
            END = m.ESITOMC