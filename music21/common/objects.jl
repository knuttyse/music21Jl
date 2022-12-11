# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         common/objects.py
# Purpose:      Commonly used Objects and Mixins
#
# Authors:      Michael Scott Asato Cuthbert
#               Christopher Ariza
#
# Copyright:    Copyright © 2009-2015 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

import inspect
import time
import weakref

import collections
using Counter
using Test

struct RelativeCounter <: Counter
    counts::Dict{Any,Int}

    function RelativeCounter()
        counts = Dict{Any,Int}()
    end

    function Base.iterate(c::RelativeCounter)
        sortedKeys = sort(keys(c.counts), by=x->c.counts[x], rev=true)
        for k in sortedKeys
            yield k
        end
    end

    function items(c::RelativeCounter)
        for k in c
            yield (k, c.counts[k])
        end
    end

    function asProportion(c::RelativeCounter)
        selfLen = sum(c.counts[x] for x in c.counts)
        outDict = Dict{Any,Int}()
        for y in c.counts
            outDict[y] = c.counts[y] / selfLen
        end
        new = RelativeCounter(outDict)
        return new
    end

    function asPercentage(c::RelativeCounter)
        selfLen = sum(c.counts[x] for x in c.counts)
        outDict = Dict{Any,Int}()
        for y in c.counts
            outDict[y] = c.counts[y] * 100 / selfLen
        end
        new = RelativeCounter(outDict)
        return new
    end
end
@test "RelativeCounter test" begin
    l = ['b', 'b', 'a', 'a', 'a', 'a', 'c', 'd', 'd', 'd'] + ['e'] * 10
    rc = RelativeCounter(l)
    
    for k in rc
        println(k, rc[k])
    end
    rcProportion = rc.asProportion()
    @test rcProportion['b'] == 0.1
    @test rcProportion['e'] == 0.5
    rcPercentage = rc.asPercentage()
    @test rcPercentage['b'] == 10.0
    @test rcPercentage['e'] == 50.0
    @test items(rc) == [('e', 10), ('a', 4), ('d', 3), ('b', 2), ('c', 1)]
    @test items(rcProportion) == [('e', 0.5), ('a', 0.2), ('d', 0.15), ('b', 0.1), ('c', 0.05)]
end

struct DefaultList{T <: AbstractList} <: AbstractList
    fx::Function
    list::T

    function DefaultList{T}(fx::Function) where T <: AbstractList
        return new{T}(fx, [])
    end
end

function _fill(dl::DefaultList, index)
    while length(dl.list) <= index
        push!(dl.list, dl.fx())
    end
end

function setindex!(dl::DefaultList, value, index)
    _fill(dl, index)
    dl.list[index] = value
end

function getindex(dl::DefaultList, index)
    _fill(dl, index)
    return dl.list[index]
end


_singletonCounter = {"value": 0}

struct SingletonCounter
    function SingletonCounter()
        _singletonCounter = Dict("value" => 0)
    end

    function ()
        post = _singletonCounter["value"]
        _singletonCounter["value"] += 1
        return post
    end
end