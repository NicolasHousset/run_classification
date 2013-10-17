# The purpose of this script is to extract relevant information concerning projects with id between 2000 and 3200.
# Reason behind this range of numbers is that projects are recent
# Projects are extracted by chunks of 100 to avoid overloading the RAM
# A db of identified peptides is built step by step

library(RMySQL);
library(data.table);

con <- dbConnect(MySQL(), group="MSDB", dbname="projects");
projectPath <- "C:/Users/Nicolas Housset/Documents/R_Projects/run_classification"

# Since it is a function the data.table will be created in the environment of the function
sampleExtract <- function(projectPath, saveName, projectStart, projectEnd, ...){
  # Beginning of the SQL statement which contains the variable we want to extract
  varSQL <- "\"SELECT scanid, number, spectrumid, l_lcrunid, l_projectid, l_instrumentid, l_protocolid, l_userid, identified, score, identitythreshold, confidence, DB,
rtsec, total_spectrum_intensity, mass_to_charge, spectrum.charge, accession, start, end, sequence, modified_sequence, identification.description FROM
(spectrum LEFT JOIN scan ON spectrum.spectrumid = scan.l_spectrumid 
LEFT JOIN identification ON spectrum.spectrumid = identification.l_spectrumid
RIGHT JOIN project ON spectrum.l_projectid = project.projectid) 
WHERE l_projectid BETWEEN ";
  varSQL <- paste0(saveName,
                   " <- data.table(dbGetQuery(con,",
                   varSQL, projectStart, " AND ", projectEnd, " AND l_instrumentid = 10;\"))");
  
  # print(varSQL);
  eval(parse(text=varSQL));
  saveText <- paste0("save(",saveName, ", file = \"", projectPath, "/data/", saveName, ".RData\", compression_level = 1)");
  # print(saveText);
  eval(parse(text=saveText));
  return(NULL);
}

# From project 2001, extract and save in chunks of 100 projects
start <- 2000
for(i in 1:12){
  start <- start + 1
  end <- start + 99
  stringExpression <- paste0("sampleExtract(",projectPath,"\"rt_project_part", i, "\", \"", start, "\", \"", end, "\")")
  start <- end
  print(stringExpression)
  eval(parse(text=stringExpression))
}

# Our database is divided into parts, we build step by step the identified peptides database
identified <- data.table(NULL)
for(i in 1:12){
  stringExpression <- paste0("load(file = \"", projectPath, "/data/rt_project_part", i, ".RData\")" )
  # print(stringExpression)
  eval(parse(text=stringExpression))
  stringExpression <- paste0("identified <- rbind(identified,rt_project_part", i, "[(!is.na(modified_sequence))])")
  # print(stringExpression)
  eval(parse(text=stringExpression))
  stringExpression <- paste0("rm(rt_project_part", i, ")")
  # print(stringExpression)
  eval(parse(text=stringExpression))
}
save(identified, file = "C:/Users/Nicolas Housset/Documents/RetentionTimeAnalysis/data/identified.RData", compression_level = 1)


