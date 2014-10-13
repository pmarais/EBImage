flip <- function (x) {
  validImage(x)
  asub(x, seq.int(dim(x)[2],1), 2)
}

flop <- function (x) {
  validImage(x)
  asub(x, seq.int(dim(x)[1],1), 1)
}

## performs an affine transform on a set of images
affine <- function (x, m, filter = c("bilinear", "none"), output.dim, bg.col = "black") {
  ## check arguments
  validImage(x)
  if (!is.matrix(m) || nrow(m)!=3 || ncol(m)!=2) stop("'m' must be a 3x2 matrix")
  if (any(is.na(m))) stop("'m' shouldn't contain any NAs")
  m <- cbind(m, c(0, 0, 1))
  filter <- match.arg(filter)
  filter <- as.integer(c(none=0, bilinear=1)[filter])
  
  # dimensions of output image
  d = dim(x)  
  if (!missing(output.dim)) {
    if(length(output.dim)!=2 || !is.numeric(output.dim)) stop("'output.dim' must be a numeric vector of length 2")
    d[1:2] = output.dim
  }
  
  ## backtransform
  m <- solve(m)
  
  ## create output image
  y <- x
  imageData(y) <- bgImage(bg.col, d, colorMode(x))
  
  .Call(C_affine, castImage(x), castImage(y), m, filter)
}

## the code of this function is based on the Image constructor and probably could be reused in a more clever way
bgImage = function(data, dim, colormode) {

  ## special character case
  if (is.character(data)) {
    data = col2rgb(data)/255
        
    if ( missing(dim) && colormode==Color )
      dim = c(dim[1:2], 3, if((ld=length(dim))>2) dim[3:ld] else NULL)
    
    if ( colormode==Color ) {
      res = abind(array(data[1,,drop=FALSE], dim[-3]), array(data[2,,drop=FALSE], dim[-3]), array(data[3,,drop=FALSE], dim[-3]), along = 2.5)
      dimnames(res) = NULL
    }
    else
      res = array(data = (data[1,,drop=FALSE] + data[2,,drop=FALSE] + data[3,,drop=FALSE]) / 3, dim = dim)
  }
  ## default numeric case
  else {
    res = array(data, dim = dim)
  }
  res
}

rotate <- function(x, angle, filter = "bilinear", output.origin = c(0, 0), ...) {
  ## check arguments
  if (length(angle)!=1 || !is.numeric(angle)) stop("'angle' must be a number")
  if (length(output.origin)!=2 || !is.numeric(output.origin)) stop("'output.origin' must be a numeric vector of length 2")
  
  theta <- angle*pi/180
  cx <- nrow(x)/2+nrow(x)*sqrt(2)*cos(theta-pi/4-pi/2)/2 + output.origin[1]
  cy <- ncol(x)/2+ncol(x)*sqrt(2)*sin(theta-pi/4-pi/2)/2 + output.origin[2]
  m <- matrix(c(cos(theta), -sin(theta), cx,
                sin(theta), cos(theta), cy), nrow=3)
  affine(x, m, filter, ...)
}

translate <- function(x, v, filter = "none", ...) {
  ## check arguments
  if (length(v)!=2 || !is.numeric(v)) stop("'v' must be a numeric vector of length 2")
  m <- matrix(c(1, 0, -v[1], 0, 1, -v[2]), nrow=3)
  affine(x, m, filter = filter, ...)
}

resize <- function(x, w, h, filter = "bilinear", output.dim = c(w, h), output.origin = c(0, 0), ...) {
  ## check arguments
  if (missing(h) && missing(w))  stop("'w' or 'h' must be specified")
  if (missing(w)) w <- round(h*dim(x)[1]/dim(x)[2])
  if (missing(h)) h <- round(w*dim(x)[2]/dim(x)[1])
  if (missing(output.dim)) output.dim <- c(w, h)
  if (length(output.origin)!=2 || !is.numeric(output.origin)) stop("'output.origin' must be a numeric vector of length 2")
  
  ratio <- c(w, h)/dim(x)[1:2]
  m <- matrix(c(ratio[1], 0, output.origin[1], 0, ratio[2], output.origin[2]), nrow=3)
  affine(x, m, filter, output.dim = output.dim, ...)
}

## transposes the XY dimensions
transpose <- function(x, coerce = FALSE) {
  validImage(x)
  dims = seq_along(dim(x))
  dims[1:2] = c(2:1)
  y = aperm(x, dims)
  if ( (!coerce) && is.Image(x) ) {
    x@.Data = y
    x
  }
  else y
}

# transposeImage = function(x, coerce = FALSE) {
#   validImage(x)
#   dims = seq_along(dim(x))
#   dims[1:2] = c(2:1)
#   y = aperm(x, dims)
#   if ( (!coerce) && is.Image(x) ) {
#     x@.Data = y
#     x
#   }
#   else y
# }
# 
# transpose <- function(x, coerce = FALSE) {
#   .Deprecated("t")
#   transposeImage(x, coerce)
# }
# 
# t.Image  <- function(x) transposeImage(x)
# t.array  <- function(x) transposeImage(x)
# t.matrix <- function(x) t.default(x)