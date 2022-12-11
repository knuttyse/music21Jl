# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         common/numberTools.py
# Purpose:      Utilities for working with numbers or number-like objects
#
# Authors:      Michael Scott Asato Cuthbert
#               Christopher Ariza
#
# Copyright:    Copyright © 2009-2022 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------
using Memoize
__all__ = [
    "ordinals", "musicOrdinals", "ordinalsToNumbers",
    "numToIntOrFloat",

    "opFrac", "mixedNumeral",
    "roundToHalfInteger",
    "addFloatPrecision", "strTrimFloat",
    "nearestMultiple",

    "dotMultiplier", "decimalToTuplet",
    "unitNormalizeProportion", "unitBoundaryProportion",
    "weightedSelection",
    "approximateGCD",

    "contiguousList",

    "groupContiguousIntegers",

    "fromRoman", "toRoman",
    "ordinalAbbreviation",
]

ordinals = [
    "Zeroth", "First", "Second", "Third", "Fourth", "Fifth",
    "Sixth", "Seventh", "Eighth", "Ninth", "Tenth", "Eleventh",
    "Twelfth", "Thirteenth", "Fourteenth", "Fifteenth",
    "Sixteenth", "Seventeenth", "Eighteenth", "Nineteenth",
    "Twentieth", "Twenty-first", "Twenty-second",
]

musicOrdinals = ordinals[:]
musicOrdinals[1] = "Unison"
musicOrdinals[8] = "Octave"
musicOrdinals[15] = "Double-octave"
musicOrdinals[22] = "Triple-octave"

const IntOrFloat = Union[Int, float]
function numToIntOrFloat(value::IntOrFloat) :: IntOrFloat
    try
        intVal = round(value)
    catch
        value = float(value)
        intVal = round(value)
    end

    if isclose(intVal, value, abs_tol=1e-6)
        return intVal
    else
        return value
    end
end

Test.@test numToIntOrFloat(1.0) == 1
Test.@test numToIntOrFloat(1.00003) == 1.00003
Test.@test numToIntOrFloat(1.5) == 1.5
Test.@test numToIntOrFloat(1.0000000005) == 1
Test.@test numToIntOrFloat(0.999999999) == 1
Test.@test numToIntOrFloat("1.0") == 1
Test.@test numToIntOrFloat("1") == 1
Test.@test numToIntOrFloat("1.0000000005") == 1
Test.@test numToIntOrFloat("0.999999999") == 1
Test.@test numToIntOrFloat("1.00003") == 1.00003
Test.@test numToIntOrFloat("1.5") == 1.5

DENOM_LIMIT = defaults.limitOffsetDenominator
@memoize function _preFracLimitDenominator(n::Int, d::Int)::Tuple{Int, Int}
    if d <= DENOM_LIMIT
        return (n, d)
    end
    nOrg = n
    dOrg = d
    p0, q0, p1, q1 = 0, 1, 1, 0
    while true
        a = div(n, d)
        q2 = q0 + a * q1
        if q2 > DENOM_LIMIT
            break
        end
        p0, q0, p1, q1 = p1, q1, p0 + a * p1, q2
        n, d = d, n - a * d
    end
    k = div(DENOM_LIMIT - q0, q1)
    bound1n = p0 + k * p1
    bound1d = q0 + k * q1
    bound2n = p1
    bound2d = q1
    bound1minusS_n = abs((bound1n * dOrg) - (nOrg * bound1d))
    bound1minusS_d = dOrg * bound1d
    bound2minusS_n = abs((bound2n * dOrg) - (nOrg * bound2d))
    bound2minusS_d = dOrg * bound2d
    difference = (bound1minusS_n * bound2minusS_d) - (bound2minusS_n * bound1minusS_d)
    if difference >= 0
        return (bound2n, bound2d)
    else
        return (bound1n, bound1d)
    end
end


Test.@test _preFracLimitDenominator(100001, 300001) == (1, 3)
Test.@test _preFracLimitDenominator(100_000_000_001, 30_0000_000_001) == (1, 3)
Test.@test _preFracLimitDenominator(1000001, 3000001) == (1, 3)

const _KNOWN_PASSES = frozenset([0.0625, 0.09375, 0.125, 0.1875, 0.25, 0.375, 0.5, 0.75, 1.0, 1.5, 2.0, 3.0, 4.0, 6.0])

function opFrac(num::Nothing)
    return nothing
end

function opFrac(num::Int)::Float64
    return convert(Float64, num)
end

function opFrac(num::Union{Float64, Fraction})::Union{Float64, Rational}
    return num
end

function opFrac(num::Union{OffsetQLIn, Nothing})::Union{OffsetQL, Nothing}
    if num in _KNOWN_PASSES
        return convert(Float64, num)
    end
    numType = typeof(num)
    if numType <: Float64
        ir = num.as_integer_ratio()
        if ir[1] > DENOM_LIMIT
            return Fraction(_preFracLimitDenominator(ir[1], ir[2]))
        else
            return num
    end
    if numType <: Int
        return convert(Float64, num)
    end
    if numType <: Rational
        d = num._denominator
        if (d & (d - 1)) == 0
            return num._numerator / convert(Float64, d)
        else
            return num
        end
    end
    if num === nothing
        return nothing
    end
    if isa(num, Int)
        return convert(Float64, num)
    end
    if isa(num, Float64)
        ir = num.as_integer_ratio()
        if ir[1] > DENOM_LIMIT
            return Rational(_preFracLimitDenominator(ir[1], ir[2]))
        else
            return num
        end
    end
    if isa(num, Rational)
        d = num.denominator
        if (d & (d - 1)) == 0
            return num.numerator / convert(Float64, d)
        else
            return num
        end
    end
    error("Cannot convert num: $num")
end

Test.@test opFrac(0.123456789) == Rational(10, 81)

const FloatOrFraction = Union{float, Fraction}

function mixedNumeral(
    expr::FloatOrFraction, 
    limitDenominator::Int=defaults.limitOffsetDenominator) -> String

end
Test.@test mixedNumeral(1.333333) == "1 1/3"
Test.@test mixedNumeral(0.333333) == "1/3"
Test.@test mixedNumeral(-1.333333) == "-1 1/3"
Test.@test mixedNumeral(-0.333333) == "-1/3"
Test.@test mixedNumeral(0) == "0"
Test.@test mixedNumeral(-0) == "0"
Test.@test mixedNumeral(Fraction(31, 7)) == "4 3/7"
Test.@test mixedNumeral(Fraction(1, 5)) == "1/5"
Test.@test mixedNumeral(Fraction(-1, 5)) == "-1/5"
Test.@test mixedNumeral(Fraction(-4, 5)) == "-4/5"
Test.@test mixedNumeral(Fraction(1, 3)) == "1/3"
Test.@test mixedNumeral(Fraction(-31, 7)) == "-4 3/7"
Test.@test mixedNumeral(Fraction(1, 2)) == "1/2"
Test.@test mixedNumeral(Fraction(2, 3)) == "2/3"
Test.@test mixedNumeral(Fraction(3, 4)) == "3/4"
Test.@test mixedNumeral(Fraction(4, 5)) == "4/5"
Test.@test mixedNumeral(Fraction(5, 6)) == "5/6"
Test.@test mixedNumeral(Fraction(6, 7)) == "6/7"
Test.@test mixedNumeral(Fraction(7, 8)) == "7/8"
Test.@test mixedNumeral(2.0000001) == "2"
Test.@test mixedNumeral(2.0000001, limitDenominator=10000000) == "2 1/10000000"

function roundToHalfInteger(num::Union{Float64, Int})
    intVal, floatVal = divrem(num, 1.0)
    intVal = convert(Int, intVal)
    if floatVal < 0.25
        floatVal = 0
    elseif 0.25 <= floatVal < 0.75
        floatVal = 0.5
    else
        floatVal = 1
    end
    return intVal + floatVal
end


Test.@test roundToHalfInteger(1.2) == 1
Test.@test roundToHalfInteger(1.35) == 1.5
Test.@test roundToHalfInteger(1.8) == 2
Test.@test roundToHalfInteger(1.6234) == 1.5
Test.@test roundToHalfInteger(0.25) == 0.5
Test.@test roundToHalfInteger(0.75) == 1
Test.@test roundToHalfInteger(1.25) == 1.5
Test.@test roundToHalfInteger(1.75) == 2
Test.@test roundToHalfInteger(-0.26) == -0.5
Test.@test roundToHalfInteger(-0.76) == -1
Test.@test roundToHalfInteger(-1.26) == -1.5
Test.@test roundToHalfInteger(-1.76) == -2

function addFloatPrecision(x, grain::Real=1e-2)
    if isa(x, String)
        x = parse(Float64, x)
    end

    values = (1 / 3, 2 / 3, 1 / 6, 5 / 6)
    for v in values
        if isapprox(x, v, atol=grain)
            return opFrac(v)
        end
    end

    return x
end

Test.@test addFloatPrecision(0.333) == opFrac(1 / 3)
Test.@test addFloatPrecision(0.33) == opFrac(1 / 3)
Test.@test addFloatPrecision(0.35) == 0.35
Test.@test addFloatPrecision(0.2) == 0.2
Test.@test addFloatPrecision(0.125) == 0.125
Test.@test addFloatPrecision(1 / 7) == 1 / 7

function strTrimFloat(floatNum::Union{Float64, Integer}, maxNum::Integer=4)
    offBuildString = "%.$maxNum" * "f"
    off = string(@sprintf(offBuildString, floatNum))
    offDecimal = findfirst(off, '.')
    offLen = length(off)
    for index in offLen-1:-1:offDecimal+1
        if off[index] != '0'
            break
        else
            offLen -= 1
        end
    end
    off = off[1:offLen]
    return off
end

Test.@test strTrimFloat(42.3333333333) == "42.3333"
Test.@test strTrimFloat(42.3333333333, 2) == "42.33"
Test.@test strTrimFloat(6.66666666666666, 2) == "6.67"
Test.@test strTrimFloat(2.0) == "2.0"
Test.@test strTrimFloat(-5) == "-5.0"

function nearestMultiple(n::Union{Float64, Integer}, unit::Union{Float64, Integer})
    if n < 0
        throw(ArgumentError("n ($(n)) is less than zero. " *
            "Thus, cannot find the nearest multiple for a value " *
            "less than the unit, $(unit)"))
    end

    mult = floor(n / unit)
    halfUnit = unit / 2.0

    matchLow = unit * mult
    matchHigh = unit * (mult + 1)
    if matchLow >= n >= matchHigh
        throw(Exception("cannot place n between multiples: $(matchLow), $(matchHigh)"))
    end

    if matchLow <= n <= (matchLow + halfUnit)
        return (matchLow, round(n - matchLow, 7), round(n - matchLow, 7))
    else
        return (matchHigh, round(matchHigh - n, 7), round(n - matchHigh, 7))
    end
end

Test.@test nearestMultiple(0.25, 0.25) == (0.25, 0.0, 0.0)
Test.@test nearestMultiple(0.35, 0.25) == (0.25, 0.1, 0.1)
Test.@test nearestMultiple(0.20, 0.25) == (0.25, 0.05, -0.05)
Test.@test nearestMultiple(0.4, 0.25) == (0.5, 0.1, -0.1)
Test.@test nearestMultiple(0.4, 0.25)[1] == 0.5
Test.@test nearestMultiple(0.4, 0.25)[2] == 0.1
Test.@test nearestMultiple(0.4, 0.25)[3] == -0.1
Test.@test nearestMultiple(23404.001, 0.125)[0]==23404.0
Test.@test nearestMultiple(23404.134, 0.125)[1]==23404.125
Test.@test nearestMultiple(23404 - 0.0625, 0.125) == (23403.875, 0.0625, 0.0625)
Test.@test nearestMultiple(0.001, 0.125)[0] == 0.0

_DOT_LOOKUP = (1.0, 1.5, 1.75, 1.875, 1.9375,
               1.96875, 1.984375, 1.9921875, 1.99609375)

function dotMultiplier(dots::Int) -> float
    if dots < 9
        return _DOT_LOOKUP[dots]
    end

    return ((2 ^ (dots + 1.0)) - 1.0) / (2 ^ dots)
end

Test.@test dotMultiplier(0) == 1.0
Test.@test dotMultiplier(1) == 1.5
Test.@test dotMultiplier(2) == 1.75
Test.@test dotMultiplier(3) == 1.875

function decimalToTuplet(decNum::Union{Float64, Integer})
    function findSimpleFraction(inner_working)
        for index in 1:1000
            for j in index:index*2
                if isapprox(inner_working, j/index, atol=1e-7)
                    return (j, index)
                end
            end
        end
        return (0, 0)
    end

    flipNumerator = false
    if decNum <= 0
        throw(DomainError("number must be greater than zero"))
    end
    if decNum < 1
        flipNumerator = true
        decNum = 1 / decNum
    end

    (unused_remainder, multiplier) = modf(decNum)
    working = decNum / multiplier

    (jy, iy) = findSimpleFraction(working)

    if iy == 0
        throw(Erro("No such luck"))
    end

    jy *= multiplier
    my_gcd = gcd(jy, iy)
    jy /= my_gcd
    iy /= my_gcd

    if flipNumerator == false
        return (jy, iy)
    else
        return (iy, jy)
    end
end


Test.@test decimalToTuplet(1.5) == (3, 2)
Test.@test decimalToTuplet(1.25) == (5, 4)
Test.@test decimalToTuplet(0.8) == (4, 5)


function unitNormalizeProportion(values::Sequence)
    summation = 0.0
    for x in values
        if x < 0.0
            throw(ValueError("value members must be positive"))
        end
        summation += x
    end

    unit = []
    for x in values
        push!(unit, x/summation)
    end
    return unit
end
Test.@test unitNormalizeProportion([0, 3, 4]) == [0.0, 0.42857142857142855, 0.5714285714285714]
Test.@test unitNormalizeProportion([1, 1, 1]) == [0.3333333333333333, 0.3333333333333333, 0.3333333333333333]
Test.@test unitNormalizeProportion([1.0, 1, 1.0]) == [0.3333333333333333, 0.3333333333333333, 0.3333333333333333]
Test.@test unitNormalizeProportion([0.2, 0.6, 0.2]) == [0.20000000000000001, 0.60000000000000009, 0.20000000000000001]


function unitBoundaryProportion(series::Sequence)
    unit = unitNormalizeProportion(series)
    bounds = []
    summation = 0.0
    for (index, x) in enumerate(unit)
        if index != length(unit) - 1
            push!(bounds, (summation, summation + x))
            summation += x
        else
            push!(bounds, (summation, 1.0))
        end
    end
    return bounds
end

Test.@test unitBoundaryProportion([1, 1, 2]) == [(0.0, 0.25), (0.25, 0.5), (0.5, 1.0)]
Test.@test unitBoundaryProportion([9, 1, 1]) == [(0.0, 0.8), (0.8, 0.9), (0.9, 1.0)]



function weightedSelection(values::Vector, weights::Vector)
    if length(values) != length(weights)
        throw(DimensionMismatch("values and weights must have the same length"))
    end

    boundaries = unitBoundaryProportion(weights)
    q = rand()

    for (index, (low, high)) in enumerate(boundaries)
        if low <= q < high
            return values[index]
        end
    end
    return values[end]
end

Test.@test -50 < sum([weightedSelection([-1, 1], [1, 1]) for x in 1:100]) < 50


function approximateGCD(values::Union{Int, Float64, Fraction}, grain::Float64 = 1e-4) -> float
    lowest = float(minimum(values))

    count = 0
    for x in values
        x_adjust = x / lowest
        floatingValue = x_adjust - int(x_adjust)
        if isclose(floatingValue, 0.0, atol=grain)
            count += 1
        end
    end
    if count == length(values)
        return lowest
    end

    divisors = (1., 2., 3., 4., 5., 6., 7., 8., 9., 10., 11., 12., 13., 14., 15., 16.)
    divisions = []
    uniqueDivisions = Set()
    for index in values
        coll = []
        for d in divisors
            v = index / d
            push!(coll, v)
            push!(uniqueDivisions, v)
        end
        push!(divisions, coll)
    end

    commonUniqueDivisions = []
    for v in uniqueDivisions
        count = 0
        for coll in divisions
            for x in coll
                if isclose(x, v, atol=grain)
                    count += 1
                    break
                end
            end
        end
        if count == length(divisions)
            push!(commonUniqueDivisions, v)
        end
    end
    if !commonUniqueDivisions
        throw(Error("cannot find a common divisor"))
    end
    return maximum(commonUniqueDivisions)
end
Test.@test approximateGCD([2.5, 10, 0.25]) == 0.25
Test.@test approximateGCD([2.5, 10]) == 2.5
Test.@test approximateGCD([2, 10]) == 2.0
Test.@test approximateGCD([1.5, 5, 2, 7]) == 0.5
Test.@test approximateGCD([2, 5, 10]) == 1.0
Test.@test approximateGCD([2, 5, 10, 0.25]) == 0.25
Test.@test strTrimFloat(approximateGCD([1/3, 2/3])) == "0.3333"
Test.@test strTrimFloat(approximateGCD([5/3, 2/3, 4])) == "0.3333"
Test.@test strTrimFloat(approximateGCD([5/3, 2/3, 4, 5])) == "0.3333"
Test.@test strTrimFloat(common.approximateGCD([5/3, 2/3, 5/6, 3/6])) == "0.1667"


function contiguousList(inputListOrTuple)
    currentMaxVal = inputListOrTuple[1]
    for index in range(1, length(inputListOrTuple))
        newVal = inputListOrTuple[index]
        if newVal != currentMaxVal + 1
            return false
        end
        currentMaxVal += 1
    end
    return true
end

@test contiguousList([3, 4, 5, 6]) == true
@test contiguousList([3, 4, 5, 6, 8]) == false
@test contiguousList([3, 4, 5, 6, 8, 7]) == false
@test contiguousList([3, 4, 5, 6, 7, 8]) == true

function groupContiguousIntegers(src::Vector{Int})
    if length(src) <= 1
        return [src]
    end
    post = []
    group = []
    sort!(src)
    i = 1
    while i < length(src)
        e = src[i]
        push!(group, e)
        eNext = src[i + 1]
        if eNext != e + 1
            push!(post, group)
            group = []
        end
        if i == length(src) - 1
            push!(group, eNext)
            push!(post, group)
        end
        i += 1
    end
    return post
end

@testset "groupContiguousIntegers test cases" begin
    @test groupContiguousIntegers([3, 5, 6]) == [[3], [5, 6]]
    @test groupContiguousIntegers([3, 4, 6]) == [[3, 4], [6]]
    @test groupContiguousIntegers([3, 4, 6, 7]) == [[3, 4], [6, 7]]
    @test groupContiguousIntegers([3, 4, 6, 7, 20]) == [[3, 4], [6, 7], [20]]
    @test groupContiguousIntegers([3, 4, 5, 6, 7]) == [[3, 4, 5, 6, 7]]
    @test groupContiguousIntegers([3]) == [[3]]
    @test groupContiguousIntegers([3, 200]) == [[3], [200]]
end

# noinspection SpellCheckingInspection
function fromRoman(num::String, strictModern=false)
    inputRoman = uppercase(num)
    subtractionValues = (1, 10, 100)
    nums = ("M", "D", "C", "L", "X", "V", "I")
    ints = (1000, 500, 100, 50, 10, 5, 1)
    places = []

    for c in inputRoman
        if !(c in nums)
            throw(ArgumentError("value is not a valid roman numeral: $inputRoman"))
        end
    end

    for (i, c) in enumerate(inputRoman)
        value = ints[findfirst(nums .== c)]
        try
            nextValue = ints[findfirst(nums .== inputRoman[i + 1])]
            if nextValue > value && value in subtractionValues
                if strictModern && nextValue >= value * 10
                    throw(ArgumentError("input contains an invalid subtraction element (modern interpretation): $num"))
                end
                value *= -1
            elseif nextValue > value
                throw(ArgumentError("input contains an invalid subtraction element: $num"))
            end
        catch
            # there is no next place.
        end
        append!(places, value)
    end

    summation = 0
    for n in places
        summation += n
    end
    return summation
end

@testset "fromRoman test cases" begin
    @test fromRoman("ii") == 2
    @test fromRoman("vii") == 7
    @test fromRoman("MCCCCLXXXIX") == 1489
    @test fromRoman("MCDLXXXIX") == 1489
    @test fromRoman("ic") == 99
    @test_throws ArgumentError fromRoman("ic", true)
end


function toRoman(num::Int)
    if !(typeof(num) <: Int)
        throw(TypeError("expected integer, got $(typeof(num))"))
    end
    if !(0 < num < 4000)
        throw(ArgumentError("Argument must be between 1 and 3999"))
    end
    ints = (1000, 900, 500, 400, 100, 90, 50, 40, 10, 9, 5, 4, 1)
    nums = ("M", "CM", "D", "CD", "C", "XC", "L", "XL", "X", "IX", "V", "IV", "I")
    result = ""
    for (i, int) in enumerate(ints)
        count = div(num, int)
        result *= nums[i] * count
        num -= int * count
    end
    return result
end

@testset "toRoman test cases" begin
    @test toRoman(2) == "II"
    @test toRoman(7) == "VII"
    @test toRoman(1999) == "MCMXCIX"
    @test_throws TypeError toRoman("hi")
    @test_throws ArgumentError toRoman(0)
end


function ordinalAbbreviation(value::Int, plural=false)
    valueHundredths = value % 100
    if valueHundredths in (11, 12, 13)
        post = "th"
    else
        valueMod = value % 10
        if valueMod == 1
            post = "st"
        elseif valueMod in (0, 4, 5, 6, 7, 8, 9)
            post = "th"
        elseif valueMod == 2
            post = "nd"
        elseif valueMod == 3
            post = "rd"
        else
            throw(ArgumentError("Something really weird"))
        end
    end

    if post != "st" && plural
        post *= "s"
    end
    return post
end
@testset "ordinalAbbreviation test cases" begin
    @test ordinalAbbreviation(3) == "rd"
    @test ordinalAbbreviation(255) == "th"
    @test ordinalAbbreviation(255, true) == "ths"
end


ordinalsToNumbers = Dict{String, Int}()
for (ordinal_index, ordinalName) in enumerate(ordinals)
    ordinalNameLower = lowercase(ordinalName)
    ordinalsToNumbers[ordinalName] = ordinal_index
    ordinalsToNumbers[ordinalNameLower] = ordinal_index
    ordinalsToNumbers[string(ordinal_index) * ordinalAbbreviation(ordinal_index)] = ordinal_index

    musicOrdinalName = musicOrdinals[ordinal_index]
    if musicOrdinalName != ordinalName
        musicOrdinalNameLower = lowercase(musicOrdinalName)
        ordinalsToNumbers[musicOrdinalName] = ordinal_index
        ordinalsToNumbers[musicOrdinalNameLower] = ordinal_index
    end
end

delete!(ordinal_index)


@testset "ordinals test cases" begin
    @testcase "ordinalsToNumbers" begin
        for (src, dst) in [(1, "I"), (3, "III"), (5, "V")]
            assert(toRoman(src) == dst)
        end
    end
    @testcase "ordinalsToNumbers" begin
        assert(ordinalsToNumbers["unison"] == 1)
        assert(ordinalsToNumbers["Unison"] == 1)
        assert(ordinalsToNumbers["first"] == 1)
        assert(ordinalsToNumbers["First"] == 1)
        assert(ordinalsToNumbers["1st"] == 1)
        assert(ordinalsToNumbers["octave"] == 8)
        assert(ordinalsToNumbers["Octave"] == 8)
        assert(ordinalsToNumbers["8th"] == 8)

        # some more suggested by copilot:
        assert(ordinalsToNumbers["second"] == 2)
        assert(ordinalsToNumbers["Second"] == 2)
        assert(ordinalsToNumbers["2nd"] == 2)
        assert(ordinalsToNumbers["ninth"] == 9)
        assert(ordinalsToNumbers["Ninth"] == 9)
        assert(ordinalsToNumbers["9th"] == 9)
    end

    @test "testWeightedSelection" begin
        # test equal selection
        for j in 1:10
            x = 0
            for i in 1:1000
                # equal chance of -1, 1
                x += weightedSelection([-1, 1], [1, 1])

            assert(-250 < x < 250)
        end

        # test a strongly weighed boundary
        for j in 1:10
            x = 0
            for i in 1:1000
                # 10000 more chance of 0 than 1.
                x += weightedSelection([0, 1], [10000, 1])
            # environLocal.printDebug(["weightedSelection([0, 1], [10000, 1])", x])
            assert(0 <= x < 20)
        end

        for j in 1:10
            x = 0
            for i in 1:1000
                # 10,000 times more likely 1 than 0.
                x += weightedSelection([0, 1], [1, 10000])
            # environLocal.printDebug(["weightedSelection([0, 1], [1, 10000])", x])
            assert(900 <= x <= 1000)
        end

        for unused_j in 1:10
            x = 0
            for i in 1:1000
                # no chance of anything but 0.
                x += weightedSelection([0, 1], [1, 0])
            # environLocal.printDebug(["weightedSelection([0, 1], [1, 0])", x])
            assert(x == 0)
        end
    end
end
