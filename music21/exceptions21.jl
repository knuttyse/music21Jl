# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         exceptions21.py
# Purpose:      music21 Exceptions (called out to not require import music21 to access)
#
# Authors:      Michael Scott Asato Cuthbert
#
# Copyright:    Copyright © 2012 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

mutable struct Music21Exception <: Exception
end

mutable struct StreamException <: StreamException
end

mutable struct ImmutableStreamException <: StreamException

mutable struct MetadataException <: Music21Exception
end

mutable struct AnalysisException <: Music21Exception
end

mutable struct TreeException <: Music21Exception
end

mutable struct InstrumentException <: Music21Exception
end

mutable struct CorpusException <: Music21Exception
end

mutable struct GroupException <: Music21Exception
end


mutable struct MeterException <: Music21Exception
end


mutable struct TimeSignatureException <: MeterException
end

mutable struct Music21DeprecationWarning <: UserWarning
end

