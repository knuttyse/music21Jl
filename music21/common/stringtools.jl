# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         common/stringTools.py
# Purpose:      Utilities for strings
#
# Authors:      Michael Scott Asato Cuthbert
#               Christopher Ariza
#
# Copyright:    Copyright © 2009-2015 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

using Test
using Sha

function remove_whitespace(s::String)
    return replace(s, r"\s+" => "")
end

Test.@test remove_whitespace("    hello \n there ") == "hellothere"
Test.@test remove_whitespace(" bye there ") == "bye there"

function whitespaceEqual(a::String, b::String)::Bool
    remove_whitespace(a) == remove_whitespace(b)
end
Test.@test whitespaceEqual("    hello \n there ", "hello there") == True

function getNumFromStr(s: str)
    numbers = "0123456789"
    found = []
    remain = []
    for char in s
        if char in numbers
            push!(found, char)
        else
            push!(remain, char)
        end
    end
    # returns numbers and then characters
    return join(found, ""), join(remain, "")
end
Test.@test getNumFromStr("23a") == ("23", "a")
Test.@test getNumFromStr("23a954Hello") == ("23954", "aHello")
Test.@test getNumFromStr("") == ("", "")

function hyphenToCamelCase(str::String, replacement::String = "-") -> str
    post = ""
    for i, word in enumerate(split(str, replacement))
        if i == 0
            post = word
        else
            post = post * capitalize(word)
        end
    end
    return post
end
Test.@test hyphenToCamelCase("movement-name") == "movementName"
Test.@test hyphenToCamelCase("movement_name", "_") == "movementName"
Test.@test hyphenToCamelCase("voice") == "voice"
Test.@test hyphenToCamelCase("music-21") == "music21"

function camelCaseToHyphen(s::String, replacement::Char = '-')::String
    post = ""
    for i, char in enumerate(s)
        if i == 0
            post = lowercase(char)
        elseif uppercase(char) == char
            post = post * replacement * lowercase(char)
        else
            post = post * char
        end
    end
    return post
end
Test.@test camelCaseToHyphen("movementName") == "movement-name"
Test.@test camelCaseToHyphen("MovementName") == "movement-name"
Test.@test camelCaseToHyphen("movementNameName") == "movement-name-name"
Test.@test camelCaseToHyphen("fileName", "_") == "file_name"
Test.@test camelCaseToHyphen("fileName", "NotFound") == "fileNotFoundName"

function spaceCamelCase(usrStr::String, replaceUnderscore::Bool=True)::String
    error("unimplemented")
end

Test.@test spaceCamelCase("thisIsATest") == "this Is A Test"
Test.@test spaceCamelCase("ThisIsATest") == "This Is A Test"
Test.@test spaceCamelCase("movement3") == "movement 3"
Test.@test spaceCamelCase("opus41no1") == "opus 41 no 1"
Test.@test spaceCamelCase("opus23402no219235") == "opus 23402 no 219235"
Test.@test spaceCamelCase("PMFC22").title() == "PMFC 22"
Test.@test spaceCamelCase("hello_myke").title() == "hello myke"

function getMd5(value::Union{String,Nothing})::String
    if value == nothing

    else
        value = string(time()) * string(rand())
    end
    
end

function hash(value::String)::String
    bytes2hex(sha256("value"))
end
Test.@test hash("test") == "9f86d081884c7d659a2feaa0c55ad015a3bf4f1b2b0b822cd15d6c15b0f00a08"

function stripAccents(inputString::String)::String
    error("unimplemented")
end    
Test.@test stripAccents("trés vite") == "tres vite"
Test.@test stripAccents("Muß") == "Muss"

function normalizeFilename(name::String)
    extension = nothing
    lenName = length(name)
    if lenName > 5 && name[4] == '.'
        extension = name[lenName - 4:end]
        name = name[1:lenName - 4]
    end
    name = stripAccents(name)
    name = replace(name, r"[^\w-]" => "_")
    if extension != nothing
        name = name * extension
    end
    return name
end
Test.@test normalizeFilename("03-Niccolò all’lessandra.not really.xml") == "03-Niccolo_alllessandra_not_really.xml"


function removePunctuation(s::String)::String
    replace.(s, [',', ';', '!', '?', '.'] => "")
end
Test.@test removePunctuation("This, is! my (face).") == "This is my face"