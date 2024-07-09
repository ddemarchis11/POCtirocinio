
CREATE OR REPLACE TABLE marketing_final.esitinotifiche AS
select
jp.Activity_Name as JOURNEY_ACTIVITY_NAME,
c.cod_istituto as COD_ABI, -- codice istituto bancario
c.COD_NDG_ANAGRAFICA_NSG as COD_NDG, -- codice anagrafica
c.COD_FISCALE_PARTITA_IVA as COD_FISCALE,
c.EMAIL_ADDRESS as EMAIL,
jp.Activity_Name as ACTIVITY_NAME,
p.ymd_hms_DateTimeSend as DATA_INVIO_HMS,
m.MICROESITO as COD_MICROESITO,
"NOTIFICHE" as COD_CANALE
from marketing_prep.notifiche p
INNER JOIN marketing_raw.cliente c on p.SubscriberKey = c.SubscriberKey
INNER JOIN marketing_prep.JourneyPrep jp on p.activity_id = jp.activity_id
INNER JOIN marketing_raw.microesiti m 
        on case
            when p.the_type = "SUCC_NO_CLICK" THEN 'notification_succ'
            when p.the_type = "SUCC_CLICK" THEN 'notification_click'
            ELSE 'SKIPPARE'
            END = m.ESITOMC
