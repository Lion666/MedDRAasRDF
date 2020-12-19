library(readxl)

MedDRA_Dic<-function(version){
  readAscFile <- function(ascFile, colNames){
    sourceFile <- paste0("data/medDRA/meddra_",version,"_english/MedAscii/", ascFile, ".asc")
    result <- read.delim2(sourceFile, 
                          header = FALSE, 
                          sep = "$", 
                          quote = "\"")
    names(result) <- colNames
    result <- result[,colNames]  
  } 

lltData <- readAscFile(ascFile="llt", colNames=c("LLT_code", "LLT", "PT_code"))
ptData <- readAscFile(ascFile="pt", colNames=c("PT_code", "PT", "null","UNK_code"))
hlt_pt <- readAscFile(ascFile="hlt_pt",colNames = c("HLT_code","PT_code"))
hltData <- readAscFile(ascFile="hlt", colNames=c("HLT_code", "HLT"))
hlgt_hlt <-readAscFile(ascFile="hlgt_hlt", colNames=c("HLGT_code","HLT_code"))
hlgtData <- readAscFile(ascFile="hlgt", colNames=c("HLGT_code", "HLGT"))
soc_hlgt <- readAscFile(ascFile = "soc_hlgt",colNames = c("SOC_code","HLGT_code"))
socData <- readAscFile(ascFile="soc", colNames=c("SOC_code", "SOC", "SOC_short"))

# Merge all Data

MedDRA_Dic<-merge(lltData,ptData,by=c("PT_code"),all = FALSE)
MedDRA_Dic<-merge(MedDRA_Dic,hlt_pt,by=c("PT_code"),all = FALSE)
MedDRA_Dic<-merge(MedDRA_Dic,hltData,by=c("HLT_code"),all = FALSE)
MedDRA_Dic<-merge(MedDRA_Dic,hlgt_hlt,by=c("HLT_code"),all = FALSE)
MedDRA_Dic<-merge(MedDRA_Dic,hlgtData,by=c("HLGT_code"),all = FALSE)
MedDRA_Dic<-merge(MedDRA_Dic,soc_hlgt,by=c("HLGT_code"),all = FALSE)
MedDRA_Dic<-merge(MedDRA_Dic,socData,by=c("SOC_code"),all = FALSE)

smq_content <- readAscFile(ascFile="smq_content", colNames=c("SMQ_code", "TERM_code", "TERM_level","TERM_scope",
                                                             "TERM_category","TERM_weight","TERM_status",
                                                             "TERM_addition_version","TERM_last_modified_version"))
smq_list <- readAscFile(ascFile = "smq_list", colNames=c("SMQ_code","SMQ_name","SMQ_level","SMQ_description",
                                                         "SMQ_source","SMQ_note","MedDRA_version","status","SMQ_algorithm"))

# TERM_scope=1 (Broad); TERM_scope=2 (Narrow)
# TERM_status='A' (Acive); TERM_status='I' (Inactive)

smq<-merge(smq_content[smq_content$TERM_level==4 & 
                       smq_content$TERM_status=='A',c("SMQ_code","TERM_code","TERM_scope")],
           smq_list[,c("SMQ_code","SMQ_name","SMQ_level")],
           by=c("SMQ_code"))
smq<-merge(smq,
           ptData[,c("PT_code","PT")],
           by.x=c("TERM_code"),
           by.y=c("PT_code"))
write.csv(MedDRA_Dic,paste0("./data/MedDRA_Dic_",version,".csv"))
write.csv(smq,paste0("./data/smq_",version,".csv"))

demotions<-read_xlsx(path=paste0("./data/medDRA/meddra_",version,"_english/version_report_",version,"_English.xlsx"),
                     sheet = "Demotions")
write.csv(demotions,paste0("./data/demotions_",version,".csv"))

}

MedDRA_Dic(version="21_1")
MedDRA_Dic(version="22_0")
MedDRA_Dic(version="22_1")
MedDRA_Dic(version="23_0")
MedDRA_Dic(version="23_1")



