trans<-function (raw, tr = "derivative", order = 1, gap = 21) 
{
  class(as.numeric(colnames(raw)))
  if (class(as.numeric(colnames(raw))) != "numeric") {
    stop("Invalid argument: the colnames of 'raw', which should be the waveband positions, are not coercible to class 'numeric'.")
  }
  if (as.numeric(colnames(raw)[1]) > as.numeric(colnames(raw)[2])) {
    test <- raw
    for (i in 1:nrow(raw)) {
      test[i, ] <- rev(test[i, ])
    }
    colnames(test) <- rev(colnames(test))
    raw <- test
    rm(test)
  }
  
  if (class(raw) == "data.frame") {
    raw <- as.matrix(raw)
  }
  # if (class(raw) != "matrix") {
  #    stop("Invalid argument: 'raw' must be of class 'matrix' or 'data.frame'.")
  # }
  
  if (is.na(match(tr, c("derivative", "continuum removed", 
                        "wavelet transformed")))) {
    stop("Invalid argument: 'tr' must be 'derivative','continuum removed' or 'wavelet transformed'")
  }
  if (tr == "derivative") {
    order <- round(order)
    if (is.na(match(order, c(0:3)))) {
      stop("Invalid argument: 'order' has to be an integer between 0 and 3.")
    }
    gap <- round(gap)
    if (is.na(match(gap, c(1:30)))) {
      stop("Invalid argument: 'gap' has be an integer between 1 and 30.")
    }
  }
  if (tr == "derivative") {
    trans <- matrix(nrow = nrow(raw), ncol = ncol(raw), dimnames = list(rownames(raw), 
                                                                        colnames(raw)))
    waveb <- as.numeric(colnames(raw))
    require(KernSmooth, quietly = T)
    for (i in 1:nrow(raw)) {
      trans[i, ] <- locpoly(waveb, raw[i, ], drv = order, 
                            bandwidth = gap, gridsize = ncol(raw))[[2]]
    }
    detach(package:KernSmooth)
  }
  if (tr == "continuum removed") {
    trans <- matrix(nrow = nrow(raw), ncol = ncol(raw), dimnames = list(rownames(raw), 
                                                                        colnames(raw)))
    waveb <- as.numeric(colnames(raw))
    require(KernSmooth, quietly = T)
    test <- raw
    for (i in 1:nrow(raw)) {
      test.1 <- cbind(waveb, test[i, ])
      test.1 <- sortedXyData(test.1[, 1], test.1[, 2])
      ch <- chull(test.1)
      ch.1 <- ch
      ch <- ch[1:(which(ch == 1))]
      ch <- sort(ch)
      ch <- c(ch, ncol(raw))
      appr.ch <- approx(test.1[ch, ], xout = test.1[, 1], 
                        method = "linear", ties = "mean")
      cr <- test.1[[2]] - appr.ch[[2]]
      trans[i, ] <- cr
    }
    trans <- trans[, 2:(ncol(raw) - 2)]
    detach(package:KernSmooth)
  }
  if (tr == "wavelet transformed") {
    waveb <- as.numeric(colnames(raw))
    waveb.1024.up <- round(max(waveb))
    waveb.1024.down <- round(min(waveb))
    waveb.1024.n <- 1023
    waveb.1024.step <- (waveb.1024.up - waveb.1024.down)/waveb.1024.n
    waveb.1024 <- c()
    waveb.1024[1] <- waveb.1024.down
    for (i in 2:1024) {
      waveb.1024[i] <- round(waveb.1024.down + (i - 1) * 
                               waveb.1024.step, 5)
    }
    raw.comp <- matrix(nrow = nrow(raw), ncol = length(waveb.1024), 
                       dimnames = list(rownames(raw), waveb.1024))
    for (i in 1:nrow(raw)) {
      raw.comp[i, ] <- round(spline(waveb, raw[i, ], method = "natural", 
                                    xout = waveb.1024)[[2]], 6)
    }
    library(wavelets)
    lev <- 7
    slo <- 3
    filte = "haar"
    trans <- matrix(nrow = nrow(raw.comp), ncol = 2^lev, 
                    dimnames = list(rownames(raw.comp), paste("WC_", 
                                                              c(1:2^lev), sep = "")))
    for (i in 1:nrow(trans)) {
      blub <- dwt(raw.comp[i, ], filter = filte)
      trans[i, ] <- slot(blub, "W")[[slo]]
    }
    detach(package:wavelets)
  }
  x11(width = 10, height = 7)
  par(mfrow = c(2, 1))
  waveb <- as.numeric(colnames(raw))
  plot(raw[1, ] ~ waveb, type = "l", ylim = c(min(raw), max(raw)), 
       xlab = "Wavebands", ylab = "Absorption or Reflection", 
       main = "Raw spectra")
  if(nrow(raw)>1){
    for (i in 2:nrow(raw)) {
      lines(raw[i, ] ~ waveb)
    }
  }
  if (tr != "wavelet transformed") {
    waveb <- as.numeric(colnames(trans))
    xl = "Wavebands"
    yl = "Absorption or Reflection"
  }
  if (tr == "wavelet transformed") {
    waveb <- c(1:128)
    xl = "Wavelet coefficients from level 3"
    yl <- "Value wavelet coefficient"
  }
  if (tr == "derivative") {
    te <- "Derivative spectra"
  }
  if (tr == "continuum removed") {
    te <- "Continuum removed spectra"
  }
  if (tr == "wavelet transformed") {
    te <- "Wavelet transformed spectra"
  }
  plot(trans[1, ] ~ waveb, type = "l", ylim = c(min(trans), 
                                                max(trans)), xlab = xl, ylab = yl, main = te)
  if(nrow(trans)>1){
    for (i in 2:nrow(raw)) {
      lines(trans[i, ] ~ waveb)
    }
  }
  output <- list(raw = raw, trans = trans, transformation = tr)
  print((trans))
  class(output) <- "trans"
  return(as.data.frame(trans))
}


transform <-function(path_to_spc, path_to_save){
  spectra <- as.data.frame(read.csv(file = path_to_spc))
  # spectra[1:3, 1:3]

  colnames(spectra)=substr(colnames(spectra),2,nchar(colnames(spectra)))
  colnames(spectra)[1] <- "sample_code"
  rownames(spectra) <- spectra$sample_code
  spectra = subset(spectra, select = -c(sample_code) )
  # (colnames(spectra))
  output = trans(spectra,"continuum removed", order=1, gap=21)
  # as.numeric(colnames(output))
  write.csv(output, path_to_save) 

  return(output)
  
}

transform("D://CropNutsDocuments/MSSC_DVC/data/spc/spc.csv","D://CropNutsDocuments/MSSC_DVC/data/spc/spc.csv")

