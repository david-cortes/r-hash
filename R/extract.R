#' Extract 
#' 
#' These are the hash accessor methods. They closely follow the R style. 
#' 
#' 
#' @param x [hash()] object 
#' @param i keys to get or set
#' @param j unused; retained to be compatoble with base package
#' @param drop unused; retained to be compatible with base package
# @param keys a vector of keys to be returned.
# @param value For the replacement method, the value(s) to be set.
#' @param ...  Arguments passed to additional methods [sapply()]
#' @param value the value to set for the key-value pair
#' @param name the key name
#'
#' `$` is a look-up operator for a single key.  The base `$` method
#' are used directly on the inherited environment.  The supplied key is taken 
#' as a string literal and is not interpreted.  The replaement form, `$<-` 
#' mutates the hash in place.
#' 
#' `[[` is the look-up, extraction operator.  It returns the value of a
#' single key and will interpret its argument. The replacement method, 
#' `[[<-` mutates the hash in place. 
#' 
#' `[` is a slice operator. It returns a hash with the subset of key-value 
#' pairs. Unlike the other accessor methods, `[` returns a *copy*. 
#' 
#' All hash key misses return `NULL`. All hash key replacements with NULL
#' delete the key-value pair from the hash.
#' 

#' `$` and `[[` return the value for the supplied argument. If 
#' `i` is not a key of `x`, `NULL` is returned with a warning.
#' 
#' `[` returns a hash slice, a subhash copy `x` with only the keys 
#' `i` defined. 
#' 
#' See details above for the complete explanation.
#' 
#' @author Christopher Brown
#' 
#' @seealso 
#' 
#'   - [del()] for removing keys
#'   - [clear()] for removing all keys
#'   - [keys()] to get/set/rename keys
#'   - [values()] to get/set/edit values
#  [set()]    to set values internal method
#'   - [hash()]  
#'   
#'   
#' @examples
#' 
#'   h <- hash( c('a','b','c'), 1:3 )
#'
#'   # NAMED ACCESS
#'   
#'   h$a  # 1
#'   h$c  # 3
#'   
#'   # class of values change automatically
#'   class(h$a)  # integer
#'   h$a <- 1.1 
#'   class(h$a)  # numeric
#'   
#'   # values can contain more complex objects
#'   h$a <- 1:6
#'   h
#'
#'   h$a <- NULL  # DELETE key 'a', will return null
#'   
#'   
#'   # INTERPRETED ACCESS
#'   
#'   h[[ "a" ]] <-"foo"    # Assigns letters, a vector to "foo"
#'   nm = "a"
#'   
#'   # SLICE ACCESS
#'   h[ nm ] <- "bar"   # h$a == bar
#'   h[ nm ] <- NULL
#'   
#'   
#'   # Slice 
#'   h[ keys(h) ]
#'   h[ keys(h) ] <- list( 1:2, 1:3 )
#'   h
#'
#' @name extract      
#' @rdname extract
#' @docType methods
#' @aliases extract

NULL


## --------------------------------------------------------------------- 
## [ : SLICE METHOD
## ---------------------------------------------------------------------

#' @name [,hash,ANY,missing,missing-method
#' @rdname extract

setMethod( 
  '[' , 
  signature( x="hash", i="ANY", j="missing", drop = "missing") ,  
  function( 
    x,i,j, ... , 
    # na.action = 
    #  if( is.null( getOption('hash.na.action') ) ) NULL else 
    #  getOption('hash.na.action') , 
    drop 
  ) {
    
    .h <- hash() # Will be the new hash
    for( k in i ) 
      assign( k, mget( x=k, envir=x@.xData, ifnotfound = list(NULL) ), .h@.Data )
    
    .h
    
  }
)


#' @name [,hash,missing,missing,missing-method
#' @rdname extract

setMethod( '[', signature( 'hash', 'missing', 'missing', 'missing' ),
  function(x,i,j, ..., drop ) {
     x                   
  }
)

## --------------------------------------------------------------------
## [<- : SLICE REPLACEMENT
## ---------------------------------------------------------------------
#   NB.  Although we would like to use assign directly, we use set 
#        because it deals with the ambiguity of the lengths of the 
#        key and value vectors.


#' @name [<-,hash,ANY,missing,ANY-method
#' @rdname extract

setReplaceMethod( '[', c(x ="hash", i="ANY" ,j="missing", value="ANY") ,
	function( x, i, ...,  value ) {
	  .set( x, i, value, ...  )  
	   x 
    }
)



#' @name [<-,hash,ANY,missing,NULL-method 
#' @rdname extract

setReplaceMethod( '[', c(x="hash", i="ANY", j="missing", value="NULL") ,
    function( x, i, ...,  value ) {
      del( i, x )
       x 
    }
)
  

# TEST:
# h[ "foo" ] <- letters # Assigns letters, a vector to "foo"
# h[ letters ] <- 1:26
# h[ keys ] <- value
# h[ 'a' ] <- NULL 



## --------------------------------------------------------------------
## $ - named accessor
##
##  $ -- DEPRECATED
##   This is deprecated since '$' is defined on environments and 
##   environments can be inherited in objects. There is not need for a
##   special functions
# ---------------------------------------------------------------------

## --------------------------------------------------------------------
## $<- - named replacement 
## --------------------------------------------------------------------
# SPECIAL CASE: NULL value
#   When assign a null values to a hash the key is deleted. It is 
#   idiomatic when setting a value to NULL in R that that value is
#   removed from a list or environment. 
#   
#   If R's behavior changes this will go away.
#   It is interesting to note that [[ behaves this way


#' @name $<-,hash,NULL-method
#' @rdname extract

setReplaceMethod( '$', c( x="hash", value="NULL"),
  function(x, name, value) {
    remove( list=name, envir=x@.Data )
    x
  }
)


## ---------------------------------------------------------------------
## [[ -- interpret accessor (DEPRECATED)
##
##   This is deprecated since this is handled by R natively.
##   Return single value, key,i, is a name/gets interpretted.
## 
## ---------------------------------------------------------------------

## ---------------------------------------------------------------------
## [[ -- interpreted replacement 
## ---------------------------------------------------------------------

#' @name [[<-,hash,ANY,missing,ANY-method
#' @rdname extract 

setReplaceMethod( '[[', c(x="hash", i="ANY", j="missing", value="ANY") ,
  function(x,i,value) {
    assign( i, value, x@.Data )
     x 
  }
)


#' @name [[<-,hash,ANY,missing,NULL-method
#' @rdname extract
  
setReplaceMethod( '[[', c(x="hash", i="ANY", j="missing", value="NULL") ,
  function(x,i,value) {
    rm( list=i, envir=x@.Data )
     x 
  }
)


