# DocOrder type in Julia
DocOrder = Vector{Union{String, Function}}

# OffsetQL type in Julia
OffsetQL = Union{Float64, Fraction}

# OffsetQLSpecial type in Julia
OffsetQLSpecial = Union{Float64, Fraction, OffsetSpecial}

# OffsetQLIn type in Julia
OffsetQLIn = Union{Int, Float64, Fraction}

# StreamType type in Julia
StreamType = TypeVar{T<:music21.stream.Stream}

# StreamType2 type in Julia
StreamType2 = TypeVar{T<:music21.stream.Stream}

# M21ObjType type in Julia
M21ObjType = TypeVar{T<:music21.base.Music21Object}

# M21ObjType2 type in Julia
M21ObjType2 = TypeVar{T<:music21.base.Music21Object}

# ClassListType type in Julia
ClassListType = Union{String, Iterable{String}, Type{M21ObjType}, Iterable{Type{M21ObjType}}}

# StepName type in Julia
StepName = Union{'C', 'D', 'E', 'F', 'G', 'A', 'B'}
