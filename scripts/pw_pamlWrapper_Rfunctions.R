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
        clean_names() %>% 
        dplyr::rename_with( ~ gsub("ln_l","lnL", .x) ) %>% 
        dplyr::rename_with( ~ str_replace_all(.x, "_d_n", "_dN")) %>% 
        dplyr::rename_with( ~ str_replace_all(.x, "_d_s", "_dS")) %>% 
        dplyr::rename_with( ~ str_replace_all(.x, "p_val", "pVal")) 
    
    if(getGeneName) {
        output <- output %>% 
            separate(seq_file, into=c("gene"), sep="_", remove=FALSE, extra="drop") %>% 
            relocate(gene)
    }
    output <- output  %>% 
        mutate(params=paste("cod",codon_model,"_omeg",initial_omega,
                            "_clean",cleandata,sep="")) %>% 
        relocate(params, .after=num_seqs) %>% 
        mutate(m0_purifying = m0vs_m0fixed_pVal<=0.05 ) %>% 
        relocate(m0_purifying, .after=m0vs_m0fixed_pVal) %>% 
        mutate(m2_pos = m2vs_m1_pVal<=0.05 ) %>% 
        relocate(m2_pos, .after=m2vs_m1_pVal)  %>% 
        mutate(m8_pos = m8vs_m7_pVal<=0.05 ) %>% 
        relocate(m8_pos, .after=m8vs_m7_pVal) %>% 
        mutate(m8a_pos = m8vs_m8a_pVal<=0.05 ) %>% 
        relocate(m8a_pos, .after=m8vs_m8a_pVal) %>% 
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
readPAMLresultsWideCombined <- function(tsv_file, 
                                        getGeneName=FALSE,
                                        markCpGresults=FALSE) {
    require(janitor)
    require(tidyverse)
    output <- read_delim(tsv_file, 
                         delim="\t",
                         show_col_types = FALSE) %>% 
        clean_names() %>% 
        dplyr::rename_with( ~ gsub("ln_l","lnL", .x) ) %>% 
        dplyr::rename_with( ~ gsub("cp_gmask","cpg_mask", .x) ) %>% 
        dplyr::rename_with( ~ str_replace_all(.x, "_d_n", "_dN")) %>% 
        dplyr::rename_with( ~ str_replace_all(.x, "_d_s", "_dS")) %>% 
        dplyr::rename_with( ~ str_replace_all(.x, "p_val", "pVal")) 
    if(getGeneName) {
        output <- output %>% 
            separate(seq_file, into=c("gene"), sep="_", remove=FALSE, extra="drop") %>% 
            relocate(gene)
    }
    # return(output)
    output <- output  %>% 
        mutate(params=paste("cod",codon_model,"_omeg",initial_omega,
                            "_clean",cleandata,sep="")) %>% 
        relocate(params, .after=num_seqs) %>% 
        ### tests on unmasked aln
        mutate(m0_purifying = m0vs_m0fixed_pVal<=0.05 ) %>% 
        relocate(m0_purifying, .after=m0vs_m0fixed_pVal) %>% 
        mutate(m2_pos = m2vs_m1_pVal<=0.05 ) %>% 
        relocate(m2_pos, .after=m2vs_m1_pVal)  %>% 
        mutate(m8_pos = m8vs_m7_pVal<=0.05 ) %>% 
        relocate(m8_pos, .after=m8vs_m7_pVal) %>% 
        mutate(m8a_pos = m8vs_m8a_pVal<=0.05 ) %>% 
        relocate(m8a_pos, .after=m8vs_m8a_pVal) %>% 
        mutate(all_tests_pos = m2_pos & m8_pos & m8a_pos) %>% 
        relocate(all_tests_pos, .after=m2_pos) %>% 
        ### tests on CpG-masked aln
        mutate(cpg_mask_m0_purifying = cpg_mask_m0vs_m0fixed_pVal<=0.05 ) %>% 
        relocate(cpg_mask_m0_purifying, .after=cpg_mask_m0vs_m0fixed_pVal) %>% 
        mutate(cpg_mask_m2_pos = cpg_mask_m2vs_m1_pVal<=0.05 ) %>% 
        relocate(cpg_mask_m2_pos, .after=cpg_mask_m2vs_m1_pVal)  %>% 
        mutate(cpg_mask_m8_pos = cpg_mask_m8vs_m7_pVal<=0.05 ) %>% 
        relocate(cpg_mask_m8_pos, .after=cpg_mask_m8vs_m7_pVal) %>% 
        mutate(cpg_mask_m8a_pos = cpg_mask_m8vs_m8a_pVal<=0.05 ) %>% 
        relocate(cpg_mask_m8a_pos, .after=cpg_mask_m8vs_m8a_pVal) %>% 
        mutate(cpg_mask_all_tests_pos = cpg_mask_m2_pos & cpg_mask_m8_pos & cpg_mask_m8a_pos) %>% 
        relocate(cpg_mask_all_tests_pos, .after=cpg_mask_m2_pos)
    return(output)
}


###### simplify_sites_strings - a little function, to take the sites column in the output of PAML pipeline (looks like this: "75_N_0.979,99_D_0.905,358_T_0.914") and to return only the site ID and the amino acid (e.g. "75N,99D,358T")
simplify_sites_strings <- function(sites_strings) {
    ## strsplit will return an NA if input was NA
    ## each_site is a list, one element per entry in the sites table, 
    ## each element is a character vector of the info for each site
    each_site <- strsplit(sites_strings, ",")
    each_site_simple <- sapply(each_site, function(x) {
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

## test readPAMLresultsWide and simplify_sites_strings
# temp <- readPAMLresultsWide("zz_allAlignments.PAMLsummaries.allParams.wide.tsv")
# temp2 <- simplify_sites_strings(temp$m8_which_sites_have_beb_0_9)
# temp2



####### getUngappedPosOneSeq and makeLookupTibble - functions to work with alignments and coordinates, making a lookup table that allows us to translate gapped to ungapped coordinates

## getUngappedPosOneSeq takes a single gapped sequence (i.e. a sequence in the alignment), and gets a tibble of position in each sequence versus position in alignment. We use cumulative sum of non-gap bases.
## makeLookupTibble is a bigger function that applies the getUngappedPosOneSeq to every sequence in an alignment and returns a tibble
## in getUngappedPosOneSeq, myGappedSeq is a DNAString (or AAString/BString, etc)
getUngappedPosOneSeq <- function(myGappedSeq) {
    mySeq <- strsplit(as.character(myGappedSeq),"")[[1]]
    myCounts <- cumsum(mySeq != "-")
    myCounts[which(mySeq=="-")] <- NA
    return(myCounts)
}

makeLookupTibble <- function(alignment) {
    output <- tibble(aln_pos=1:width(alignment)[1])
    each_seq_lookup <- sapply( names(alignment), function(each_seq_name) {
        getUngappedPosOneSeq( alignment[[each_seq_name]] )
    } ) 
    output <- bind_cols(output, each_seq_lookup)
    return(output)
}



##### format_numbers_nicely function - intended to take p-values and display them in a nicer way.   I want very small numbers to be shown in scientific notation (e.g. "6.11e-05") but less small numbers to be shown as ordinary numeric values, (e.g. "0.406"). In both cases I do some rounding

format_numbers_nicely <- function(x,
                                  thresholdForVerySmall=0.001,
                                  verySmallNumberDigits=2,
                                  lessSmallNumberDigits=3) {
    y <- case_when(
        x < thresholdForVerySmall ~ signif(x, verySmallNumberDigits) %>% 
            as.character(), 
        TRUE ~ round (x, lessSmallNumberDigits) %>% 
            as.character()
    )
    return(y)
}
# PAML_table_to_use$m8vs_m8a_pVal
#  [1] 6.1097e-05 2.0450e-02 2.1851e-02 3.1046e-02 6.4299e-02 1.7979e-01
#  [7] 3.2573e-01 4.0610e-01 9.4444e-01 9.9323e-01 9.9414e-01 1.0000e+00
# [13] 1.0000e+00 1.0000e+00 1.0000e+00 1.0000e+00 1.0000e+00 1.0000e+00
# format_numbers_nicely(PAML_table_to_use$m8vs_m8a_pVal)
#  [1] "6.1e-05" "0.02"    "0.022"   "0.031"   "0.064"   "0.18"    "0.326"  
#  [8] "0.406"   "0.944"   "0.993"   "0.994"   "1"       "1"       "1"      
# [15] "1"       "1"       "1"       "1"  


#### displays PAML output as kable, dropping some unneeded columns and doing some rounding.
## xxx wrote this for a separate script (~/FH_fast_storage/paml_screen/Jyoti_Batra_SARS/MTARC2_TOMM70_MAVS_resultsSummary.Rmd). 
## xxx later then I made it play nicely with readPAMLresultsWide (so it probably no longer works for the Jyoti script)
## xx have not tested include_more_cols
display_PAML_output_nicely <- function(
        paml_tbl,
        include_GARD_cols=FALSE,
        include_CpG_cols=TRUE,
        include_more_cols=NULL, 
        include_pos_cols=TRUE,
        cols_to_color=c("m8vs_m8a_pVal","m8vs_m7_pVal","m2vs_m1_pVal",
                        "m8a_pos", "m8_pos", "m2_pos", "all_tests_pos"),
        cols_color="orange",
        color_signif_rows=TRUE,
        signif_rows_color="red",
        roundDigits=3,
        caption=NULL,
        return_tbl=FALSE,
        write_excel=FALSE, excel_file=NULL) {
    
    cols_to_choose <- c("gene")
    if("cpg_mask" %in% colnames(paml_tbl)) {
        cols_to_choose <- c(cols_to_choose, "cpg_mask")
    }
    if(!is.null(include_more_cols)) {
        missingCols <- setdiff(include_more_cols, colnames(paml_tbl))
        if(length(missingCols)>0) {
            stop("\n\nERROR - in the include_more_cols option, you specified columns that don't exist in the data: ", missingCols, "\n\n")
        }
        cols_to_choose <- c(cols_to_choose, include_more_cols)
    }
    if(include_GARD_cols) {
        cols_to_choose <- c(cols_to_choose, "segmentID", "seg_start", "seg_end")
    }
    cols_to_choose <- c(cols_to_choose, 
                        "num_seqs","num_aa","m0_overall_dN_dS",
                        "m0_total_dS_tree_length",
                        "m8vs_m8a_pVal","m8vs_m7_pVal","m2vs_m1_pVal")
    if(include_pos_cols) { 
        cols_to_choose <- c(cols_to_choose, "m8a_pos", "m8_pos", "m2_pos", "all_tests_pos")
    }
    cols_to_choose <- c(cols_to_choose,
                        "m8_percent_sites_under_positive_selection",
                        "m8_dN_dS_of_selected_sites")
    if(include_CpG_cols) {
        cols_to_choose <- c(cols_to_choose, 
                            "cpg_mask_m8vs_m8a_pVal",
                            "cpg_mask_m8vs_m7_pVal",
                            "cpg_mask_m2vs_m1_pVal")
        if(include_pos_cols) { 
            cols_to_choose <- c(cols_to_choose, 
                                "cpg_mask_m8a_pos", "cpg_mask_m8_pos", 
                                "cpg_mask_m2_pos", "cpg_mask_all_tests_pos")
        }
    }
    
    ### get relevant columns and do some rounding
    
    ## original rounding scheme (less sophisticated):
    # paml_tbl_nice <- paml_tbl %>% 
    #     select(all_of(cols_to_choose)) %>%
    #     mutate(across(.cols=where(is.numeric),
    #                   .fns= function(x) { round(x, roundDigits) })) %>%
    #     mutate(across(.cols=c(m8_percent_sites_under_positive_selection,
    #                           m8_dN_dS_of_selected_sites),
    #                   .fns= function(x) { round(x, 1) })) 
    
    ## use format_numbers_nicely function for the p-value columns
    paml_tbl_nice <- paml_tbl %>% 
        select(all_of(cols_to_choose)) 
    
    pValue_colnames <- grep("_pVal", colnames(paml_tbl_nice), value=TRUE)
    colnames_for_short_rounding <- c("m8_percent_sites_under_positive_selection",
                                     "m8_dN_dS_of_selected_sites")
    all_numeric_colnames <- paml_tbl_nice %>% 
        select(where(is.numeric)) %>% colnames()
    remaining_numeric_colnames <- setdiff(
        all_numeric_colnames, 
        c(pValue_colnames,colnames_for_short_rounding))
    # cat("all_numeric_colnames", all_numeric_colnames, "\n")
    # cat("remaining_numeric_colnames", remaining_numeric_colnames, "\n")
    
    paml_tbl_nice <- paml_tbl_nice %>% 
        mutate(across(.cols=all_of(pValue_colnames),
                      .fns= format_numbers_nicely)) %>%
        mutate(across(.cols=all_of(colnames_for_short_rounding),
                      .fns= function(x) { round(x, 1) })) %>% 
        mutate(across(.cols=all_of(remaining_numeric_colnames),
                      .fns= function(x) { round(x, roundDigits) }))
    
    ### figure out indices of any columns/rows we want to color
    if(!is.null(cols_to_color)) {
        color_column_indices <- which(colnames(paml_tbl_nice) %in% cols_to_color)
    }
    if (color_signif_rows) {
        color_row_indices <- which(paml_tbl_nice$all_tests_pos)
    } 
    
    ### we don't always want to return a kable object - sometimes we want just the tbl
    
    ### fixing colnames and formatting table
    paml_tbl_nice <- paml_tbl_nice %>%
        rename_with(.fn = ~gsub("_"," ",.x) ) 
    
    ### other colname replacements:
    paml_tbl_nice <- paml_tbl_nice %>%
        rename_with(.fn = function(x) { 
            x <- gsub("pVal","p-value",x) 
            x <- gsub("vs m"," vs ",x) 
            x <- gsub("^m0","model 0",x) 
            x <- gsub("^m8","model 8",x) 
            x <- gsub("^m2","model 2",x) 
            x <- gsub("mask m8","mask model 8",x) 
            x <- gsub("mask m2","mask model 2",x) 
            x <- gsub("dN dS","dN/dS",x) 
            x <- gsub("BHcorr","(BH-corrected)",x) 
            return(x)
        } )
    
    ### maybe we write an Excel file
    if (write_excel) {
        require(openxlsx, quietly=TRUE)
        wb <- createWorkbook()
        addWorksheet(wb, "Sheet 1")
        writeData(wb, "Sheet 1", paml_tbl_nice)
        
        ## arial font size 12
        modifyBaseFont(wb, fontSize = 12, fontName = "Arial")
        
        ## zoom setting
        ## wrap colnames
        ## bold first row and top align
        colnames_style <- createStyle(wrapText = TRUE,
                                      textDecoration = "bold",
                                      valign = "top")
        addStyle(wb, sheet=1, style=colnames_style, 
                 rows = 1, cols=1:dim(paml_tbl_nice)[2],
                 gridExpand = TRUE)
        
        ## autofit col widths
        setColWidths(wb, sheet=1, cols=1:dim(paml_tbl_nice)[2], widths = "auto")
        
        saveWorkbook(wb, excel_file, overwrite = TRUE)
    }
    ## if return_tbl=TRUE we stop here and return paml_tbl_nice
    if(return_tbl) {
        return(paml_tbl_nice)
    }
    ## otherwise we make a kable formatted object and return that
    paml_tbl_nice <- paml_tbl_nice %>%
        kable(caption=caption) %>% 
        kable_styling(full_width=FALSE)
    if(!is.null(cols_to_color)) {
        paml_tbl_nice <- paml_tbl_nice %>% 
            column_spec(color_column_indices, color = cols_color)
    }
    if(color_signif_rows) {
        paml_tbl_nice <- paml_tbl_nice %>% 
            row_spec(color_row_indices, color = signif_rows_color)
    }
    return(paml_tbl_nice)
}

