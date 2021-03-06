\name{bwlabel}

\alias{bwlabel}

\title{Binary segmentation}

\description{
  Labels connected (connected sets) objects in a binary image.
}

\usage{
bwlabel(x)
}

\arguments{
  \item{x}{An \code{Image} object or an array. \code{x} is considered as
    a binary image, whose pixels of value 0 are considered as background
    ones and other pixels as foreground ones.}
}

\value{
  A \code{Grayscale} \code{Image} object or an array, containing the
  labelled version of \code{x}.
}

\details{
  All pixels for each connected set of foreground (non-zero) pixels
  in \code{x} are set to an unique increasing integer, starting from 1.
  Hence, \code{max(x)} gives the number of connected objects in \code{x}.
}

\author{
  Gregoire Pau, 2009
}

\seealso{
  \code{\link{computeFeatures}}, \code{\link{propagate}}, \code{\link{watershed}}, \code{\link{paintObjects}}, \code{\link{colorLabels}}
}

\examples{
  ## simple example
  x = readImage(system.file('images', 'shapes.png', package='EBImage'))
  x = x[110:512,1:130]
  display(x, title='Binary')
  y = bwlabel(x)
  display(normalize(y), title='Segmented')

  ## read nuclei images
  x = readImage(system.file('images', 'nuclei.tif', package='EBImage'))
  display(x)

  ## computes binary mask
  y = thresh(x, 10, 10, 0.05)
  y = opening(y, makeBrush(5, shape='disc'))
  display(y, title='Cell nuclei binary mask')

  ## bwlabel
  z = bwlabel(y)
  display(normalize(z), title='Cell nuclei')
  nbnuclei = apply(z, 3, max)
  cat('Number of nuclei=', paste(nbnuclei, collapse=','),'\n')

  ## recolor nuclei in colors
  cols = c('black', sample(rainbow(max(z))))
  zrainbow = Image(cols[1+z], dim=dim(z))
  display(zrainbow, title='Cell nuclei (recolored)')
}
