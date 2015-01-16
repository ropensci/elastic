#' Time units
#' 
#' Whenever durations need to be specified, eg for a timeout parameter, the duration can 
#' be specified as a whole number representing time in milliseconds, or as a time value 
#' like 2d for 2 days. The supported units are:
#' 
#' \tabular{ll}{ 
#' y \tab Year \cr
#' M \tab Month \cr
#' w \tab Week \cr
#' d \tab Day \cr
#' h \tab Hour \cr
#' m \tab Minute \cr
#' s \tab Second \cr
#' }
#' 
#' @name units-time
#' @seealso \code{\link{units-distance}}
NULL

#' Distance units
#' 
#' Wherever distances need to be specified, such as the distance parameter in the 
#' Geo Distance Filter), the default unit if none is specified is the meter. Distances 
#' can be specified in other units, such as "1km" or "2mi" (2 miles).
#' 
#' \tabular{ll}{ 
#' mi or miles \tab Mile \cr
#' yd or yards \tab Yard \cr
#' ft or feet \tab Feet \cr
#' in or inch \tab Inch \cr
#' km or kilometers \tab Kilometer \cr
#' m or meters \tab Meter \cr
#' cm or centimeters \tab Centimeter \cr
#' mm or millimeters \tab Millimeter \cr
#' NM, nmi or nauticalmiles \tab Nautical mile \cr
#' }
#' 
#' The precision parameter in the Geohash Cell Filter accepts distances with the above 
#' units, but if no unit is specified, then the precision is interpreted as the length 
#' of the geohash.
#' 
#' @name units-distance
#' @seealso \code{\link{units-time}}
NULL
