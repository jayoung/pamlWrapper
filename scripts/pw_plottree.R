### call this script using a command like this:  Rscript pw_plottree.R treefile1 treefile2 >& logfile.Rout

####### some setup / defaults

plotType <- "phylogram"
myCex <- 1
myScalePosX <- 2
myScalePosY <- 2
myTitlePosX <- "default"
myTitlePosY <- "default"
myPageWidth <- 11
myPageHeight <- 7
myNodeXadj <- 1.2  ### higher number moves node label to the left
myNodeYadj <- -0.5  ### higher number moves node label down
myNodeColor <- "black"
root <- FALSE
outgroup <- NULL

myMargins <- c(0,0,0.5,0)

### whether to plot the bootstrap values.
plotbootstrap <- TRUE

### sometimes bootstraps are given as proportion, and I'd rather see them as percentage
multiplyBootstraps <- FALSE
bootstrapMultiplier <- 100
roundBootstraps <- TRUE
minBootstrapToShow <- 0

###### parse the command line
allargs <- commandArgs(TRUE)

filenames <- grep("=", allargs, invert=TRUE, value=TRUE)
cat ("files ", filenames, "\n")

otherargs <- grep("=", allargs, value=TRUE)
if (length(otherargs)>0) {
    cat ("options2 ", otherargs, "\n")
    otherargs <- strsplit(otherargs, "=")
    x <- lapply(otherargs, function(x) {assign(x[1], x[2], pos=1)})
}

if (!exists("myScaleFontCex")) {
    cat("setting myScaleFontCex to match myCex\n")
    myScaleFontCex <- myCex
}
if (!exists("myNodeFontCex")) {
    cat("setting myNodeFontCex to match myCex\n")
    myNodeFontCex <- myCex 
}
if (!exists("myTitleCex")) { 
    cat("setting myTitleCex to match myCex\n")
    myTitleCex <- myCex 
}
aliasTable <- data.frame()
if (exists("aliasFile")) {
    if(!file.exists(aliasFile)) {
        stop("\n\nERROR in pw_plottree.R - aliasFile",aliasFile,"was specified but it does not exist\n\n")
    }
    cat("using aliasFile",aliasFile)
    aliasTable <- read.delim(aliasFile, header=FALSE)
}
cat ("\n\n")

##################
library(ape)

for (treefile in filenames) {
    cat ("working on file ", treefile, "\n")
    tree <- read.tree(treefile)

    if (exists("aliasFile")) {
        newTipLabels <- tree$tip.label
        gotNewLabels <- match(tree$tip.label, aliasTable[,2])
        newTipLabels[which(!is.na(gotNewLabels))] <- aliasTable[which(!is.na(gotNewLabels)),1]
        tree$tip.label <- newTipLabels
    }

    if (root) {
        if (is.null(outgroup)) {
            cat("Problem - requested rooting of the tree, but no outgroup was specified. Skipping this one!\n")
            next()
        }
        #cat("rooted? ", is.rooted(tree), "\n")
        tree <- root(tree, outgroup, resolve.root=TRUE)
        #cat("rooted? ", is.rooted(tree), "\n")
    }
    
    if (plotbootstrap) {
        myTempLabels <- as.numeric(tree$node.label)
        if (multiplyBootstraps) { myTempLabels <- bootstrapMultiplier * as.numeric(myTempLabels) }
        if (roundBootstraps) { myTempLabels <- round(myTempLabels) }
        myTempLabels[which(myTempLabels<minBootstrapToShow)] <- NA
        tree$node.label <- myTempLabels
    }
    
    outname <-paste(treefile,".names.pdf",sep="")
    pdf(file=outname, height=as.numeric(myPageHeight),width=as.numeric(myPageWidth))
    #X11(height=as.numeric(myPageHeight),width=as.numeric(myPageWidth))
    par(mar=myMargins)
    #plot.phylo(tree,font=1,cex=as.numeric(myCex),no.margin=T,type=plotType)
    plot.phylo(tree,font=1,cex=as.numeric(myCex),type=plotType)
    if (plotbootstrap) { 
        if (length(tree$node.label)==0) {
            cat("\n    Warning - asked for plot to include bootstrap values, but there were none\n\n")            
        } else {
            nodelabels( tree$node.label, adj=c(as.numeric(myNodeXadj),as.numeric(myNodeYadj)), col=myNodeColor, frame="none", cex=as.numeric(myNodeFontCex) )
        }
    }
    add.scale.bar(x=as.numeric(myScalePosX), y=as.numeric(myScalePosY), length=0.2, cex=as.numeric(myScaleFontCex))
    if ((myTitlePosX == "default") & (myTitlePosY == "default")) {
        #cat("adding title\n")
        title(treefile, cex.main=as.numeric(myTitleCex))
    } else {
        if(myTitlePosY=="top") { myTitlePosY= length(tree$tip.label)+1 }
        if(myTitlePosY=="bottom") { myTitlePosY= 1 }
        #cat("adding text\n")
        text(as.numeric(myTitlePosX),as.numeric(myTitlePosY),treefile, cex=as.numeric(myTitleCex))
    }
    dev.off()
}

if (!is.null(warnings())) {
    cat("printing warnings, if any\n")
    warnings()
}
cat("\n\nfinished\n\n");
q(save="no")
