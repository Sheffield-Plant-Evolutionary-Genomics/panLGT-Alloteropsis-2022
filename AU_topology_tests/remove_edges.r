library(phytools)
tr1<-read.tree("RAxML_bestTree.CONSTRAINTS-2")
tr1$edge.length<-NULL
write.tree(tr1,file="CONSTRAINTS")
