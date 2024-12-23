CREATE EXTERNAL TABLE my_ingested_data (
element_clicked STRING,
time_spent INT,
source_menu STRING,
created_at STRING
)
PARTITIONED BY (
datehour STRING
)
ROW FORMAT SERDE 'org.openx.data.jsonserde.JsonSerDe'
with serdeproperties ( 'paths'='element_clicked, time_spent, source_menu, created_at' )
LOCATION "s3://analytics-data-961109809677-20241208-36dd79aae713/"
TBLPROPERTIES (
"projection.enabled" = "true",
"projection.datehour.type" = "date",
"projection.datehour.format" = "yyyy/MM/dd/HH",
"projection.datehour.range" = "2021/01/01/00,NOW",
"projection.datehour.interval" = "1",
"projection.datehour.interval.unit" = "HOURS",
"storage.location.template" = "s3://analytics-data-961109809677-20241208-36dd79aae713/${datehour}/"
)