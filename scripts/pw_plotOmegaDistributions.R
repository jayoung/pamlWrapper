####

### can call this script as follows:
##  Rscript pw_plotOmegaDistributions.R myTitle=gene001_CENPA/paml_speciesTree outputPlotFile=gene001_CENPA/paml_speciesTree/omegaDistributions.pdf M1p=0.95078,0.04922 M1w=0.02918,1.00000 M2p=0.99389,0.00000,0.00611 M2w=0.05613,1.00000,4.91857 M7p=0.10000,0.10000,0.10000,0.10000,0.10000,0.10000,0.10000,0.10000,0.10000,0.10000 M7w=0.00000,0.00000,0.00000,0.00000,0.00000,0.00000,0.00009,0.00320,0.07230,0.71366 M8p=0.09940,0.09940,0.09940,0.09940,0.09940,0.09940,0.09940,0.09940,0.09940,0.09940,0.00604 M8w=0.02513,0.03410,0.04035,0.04586,0.05119,0.05673,0.06282,0.07006,0.07980,0.09788,4.94142 M8ap=0.09511,0.09511,0.09511,0.09511,0.09511,0.09511,0.09511,0.09511,0.09511,0.09511,0.04891 M8aw=0.00369,0.00829,0.01254,0.01690,0.02163,0.02699,0.03338,0.04155,0.05338,0.07734,1.00000 >& gene001_CENPA/paml_speciesTree/plotOmegaDistributions.logfile.Rout

##### process args
allargs <- commandArgs(TRUE)

wellFormattedArgs <- grep("=", allargs, value=TRUE)
if (length(wellFormattedArgs)>0) {
    wellFormattedArgs <- strsplit(wellFormattedArgs, "=")
    x <- lapply(wellFormattedArgs, function(x) {
        assign(x[1], x[2], pos=1)
    })
}



###################

allModels <- c("M0","M1","M2","M7","M8","M8a")

getParams <- function( modelName ) {
    pVals <- get(paste(modelName,"_p",sep=""))
    wVals <- get(paste(modelName,"_w",sep=""))
    if (grepl(",",pVals)[1]) {
        pVals <- as.numeric(strsplit(pVals,",")[[1]])
        wVals <- as.numeric(strsplit(wVals,",")[[1]])
    }
    myList <- list()
    myList[["p"]] <- pVals
    myList[["w"]] <- wVals
    return(myList)
}
allParams <- lapply(allModels, getParams)
names(allParams) <- allModels

maxOmega <- 1.5
plotModel <- function( modelName ) {
    wVals <- allParams[[modelName]][["w"]]
    pVals <- allParams[[modelName]][["p"]]
    #cat ("        wVals",wVals,"\n")
    #cat ("        pVals",pVals,"\n")
    myCols <- rep("red", length(wVals))
    if (sum(wVals>maxOmega)>0) {
        myCols [ which (wVals>maxOmega) ] <- "black"
        wVals [ which (wVals>maxOmega) ] <- maxOmega
    }
    if (length(wVals)>1) { 
        summedPvals <- tapply( pVals, wVals, sum) 
    } else {
        summedPvals <- pVals
        names(summedPvals) <- wVals
    }
    plot ( as.numeric(names(summedPvals)), summedPvals, "h", xlim=c(0,maxOmega), ylim=c(0,1), xlab="omega", ylab="fraction of sites", main=modelName, lwd=3, col=myCols)
}

pdf(file=outputPlotFile, height=11,width=7)
par(mfrow=c(6,1), oma=c(0,0,2,0))
for (model in allModels) {
    plotModel(model)
}
title (main=myTitle, outer=TRUE)
dev.off()
q(save="no")

