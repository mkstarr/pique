#!/usr/bin/env python
cimport cython
cimport numpy
import numpy
import pique

DTYPE = numpy.float64
ctypedef numpy.float64_t DTYPE_t

@cython.boundscheck(False)
def peakdet( v,            \
             delta,         \
             x = None):
    """
    Converted from MATLAB script at http://billauer.co.il/peakdet.html
    
    Currently returns two lists of tuples, but maybe arrays would be better
    
    function [maxtab, mintab]=peakdet(v, delta, x)
    %PEAKDET Detect peaks in a vector
    %        [MAXTAB, MINTAB] = PEAKDET(V, DELTA) finds the local
    %        maxima and minima ("peaks") in the vector V.
    %        MAXTAB and MINTAB consists of two columns. Column 1
    %        contains indices in V, and column 2 the found values.
    %      
    %        With [MAXTAB, MINTAB] = PEAKDET(V, DELTA, X) the indices
    %        in MAXTAB and MINTAB are replaced with the corresponding
    %        X-values.
    %
    %        A point is considered a maximum peak if it has the maximal
    %        value, and was preceded (to the left) by a value lower by
    %        DELTA.
    
    % Eli Billauer, 3.4.05 (Explicitly not copyrighted).
    % This function is released to the public domain; Any use is allowed.
    
    """
    v = numpy.asarray( v, dtype=numpy.float64 )

    maxtab = []
    mintab = []
    
    cdef DTYPE_t mx = numpy.inf
    cdef DTYPE_t mn = -numpy.inf
    
    cdef DTYPE_t mxpos = numpy.nan
    cdef DTYPE_t mnpos = numpy.nan
    
    cdef DTYPE_t this = 0
    
    if x is None:
        x = numpy.arange(len(v))
    else :    
        x = numpy.asarray( x, dtype=numpy.float64 )
    
    if len(v) != len(x):
        raise pique.PiqueException( 'Input vectors v and x must have same length')
    
    if not numpy.isscalar(delta):
        raise pique.PiqueException( 'Input argument delta must be a scalar')
    
    if delta <= 0:
        raise pique.PiqueException( 'Input argument delta must be positive')
    
    lookformax = True
    
    for i in numpy.arange(len(v)):
        this = v[i]
        if this > mx:
            mx = this
            mxpos = x[i]
        if this < mn:
            mn = this
            mnpos = x[i]
        
        if lookformax:
            if this < mx-delta:
                maxtab.append((mxpos, mx))
                mn = this
                mnpos = x[i]
                lookformax = False
        else:
            if this > mn+delta:
                mintab.append((mnpos, mn))
                mx = this
                mxpos = x[i]
                lookformax = True

    return maxtab, mintab