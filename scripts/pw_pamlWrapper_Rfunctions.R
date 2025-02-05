## useful functions.  use source("pamlWrapper/scripts/pw_pamlWrapper_Rfunctions.R") to read them into your R session



#### readPAMLresultsWide - works on wide.tsv files. Reads into R session, and makes a few new columns to indicate whether the p-values are interesting
# getGeneName=FALSE:  if TRUE, will get gene name from input seq file name, assuming gene name is the first field before an underscore
# markCpGresults=FALSE:  if TRUE, will detect whether input file was CpG masked, and tag params accordingly
readPAMLresultsWide <- function(tsv_file, 
                                getGeneName=FALSE,
                                markCpGresults=FALSE) {
    require(janitor)
    require(tidyverse)
    output <- read_delim(tsv_file, 
                         delim="\t",
                         show_col_types = FALSE) %>% 
        clean_names()
    if(getGeneName) {
        output <- output %>% 
            separate(seq_file, into=c("gene"), sep="_", remove=FALSE, extra="drop") %>% 
            relocate(gene)
    }
    output <- output  %>% 
        mutate(params=paste("cod",codon_model,"_omeg",initial_omega,
                            "_clean",cleandata,sep="")) %>% 
        relocate(params, .after=num_seqs) %>% 
        mutate(m0_purifying = m0vs_m0fixed_p_val<=0.05 ) %>% 
        relocate(m0_purifying, .after=m0vs_m0fixed_p_val) %>% 
        mutate(m2_pos = m2vs_m1_p_val<=0.05 ) %>% 
        relocate(m2_pos, .after=m2vs_m1_p_val)  %>% 
        mutate(m8_pos = m8vs_m7_p_val<=0.05 ) %>% 
        relocate(m8_pos, .after=m8vs_m7_p_val) %>% 
        mutate(m8a_pos = m8vs_m8a_p_val<=0.05 ) %>% 
        relocate(m8a_pos, .after=m8vs_m8a_p_val) %>% 
        mutate(all_tests_pos = m2_pos & m8_pos & m8a_pos) %>% 
        relocate(all_tests_pos, .after=m2_pos)
    
    if(markCpGresults) {
        output <- output %>% 
            mutate(cpg_mask=str_detect(seq_file, "removeCpG")) %>% 
            relocate(cpg_mask, .after=tree_file)  %>% 
            mutate(params=case_when(cpg_mask ~ paste("mask_",params,sep=""),
                                    TRUE ~ paste("unmask_",params,sep="")))
    }
    return(output)
}

### readPAMLresultsWideCombined - works on wide.combineMasking.tsv files

## xxx want a version of this that works on the 'combined' wide.csv files, where I already put CpG results next to unmasked results

readPAMLresultsWideCombined <- function(tsv_file, 
                                        getGeneName=FALSE,
                                        markCpGresults=FALSE) {
    stop("\n\nERROR - need to finish making this function\n\n")
    require(janitor)
    require(tidyverse)
    output <- read_delim(tsv_file, 
                         delim="\t",
                         show_col_types = FALSE) %>% 
        clean_names()
    if(getGeneName) {
        output <- output %>% 
            separate(seq_file, into=c("gene"), sep="_", remove=FALSE, extra="drop") %>% 
            relocate(gene)
    }
    output <- output  %>% 
        mutate(params=paste("cod",codon_model,"_omeg",initial_omega,
                            "_clean",cleandata,sep="")) %>% 
        relocate(params, .after=num_seqs) %>% 
        mutate(m0_purifying = m0vs_m0fixed_p_val<=0.05 ) %>% 
        relocate(m0_purifying, .after=m0vs_m0fixed_p_val) %>% 
        mutate(m2_pos = m2vs_m1_p_val<=0.05 ) %>% 
        relocate(m2_pos, .after=m2vs_m1_p_val)  %>% 
        mutate(m8_pos = m8vs_m7_p_val<=0.05 ) %>% 
        relocate(m8_pos, .after=m8vs_m7_p_val) %>% 
        mutate(m8a_pos = m8vs_m8a_p_val<=0.05 ) %>% 
        relocate(m8a_pos, .after=m8vs_m8a_p_val) %>% 
        mutate(all_tests_pos = m2_pos & m8_pos & m8a_pos) %>% 
        relocate(all_tests_pos, .after=m2_pos)
    
    if(markCpGresults) {
        output <- output %>% 
            mutate(cpg_mask=str_detect(seq_file, "removeCpG")) %>% 
            relocate(cpg_mask, .after=tree_file)  %>% 
            mutate(params=case_when(cpg_mask ~ paste("mask_",params,sep=""),
                                    TRUE ~ paste("unmask_",params,sep="")))
    }
    return(output)
}

###### simplify_sites_strings - a little function, to take the sites column in the output of PAML pipeline (looks like this: "75_N_0.979,99_D_0.905,358_T_0.914") and to return only the site ID and the amino acid (e.g. "75N,99D,358T")
simplify_sites_strings <- function(sites_strings) {
    ## strsplit will return an NA if input was NA
    ## each_site is a list, one element per entry in the sites table, 
    ## each element is a character vector of the info for each site
    each_site <- strsplit(sites_strings, ",")
    each_site_simple <- lapply(each_site, function(x) {
        each_site_split <- strsplit(x, "_")
        each_analysis_simple <- sapply(each_site_split, function(y) {
            if(is.na(y[1])) {return(NA)}
            new_site <- paste(y[1:2], collapse="")
            return(new_site)
        }, USE.NAMES = FALSE) 
        each_analysis_simple <- paste(each_analysis_simple, collapse=",")
        return(each_analysis_simple)
    })
    return(each_site_simple)
}


## test readPAMLresultsWide
# temp <- readPAMLresultsWide("zz_allAlignments.PAMLsummaries.allParams.wide.tsv")
# temp2 <- simplify_sites_strings(temp$m8_which_sites_have_beb_0_9)
# temp2
