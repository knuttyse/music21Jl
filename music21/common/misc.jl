# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         common/misc.py
# Purpose:      Everything that doesn't fit into anything else.
#
# Authors:      Michael Scott Asato Cuthbert
#               Christopher Ariza
#
# Copyright:    Copyright © 2009-2020 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

function flattenList{T}(originalList::Iterable{Iterable[T]}) -> Iterable{T}
    [item for sublist in originalList for item in sublist]
end

Test.@test flattenList([[1, 2, 3], [4, 5], [6]]) == [1, 2, 3, 4, 5, 6]

function getPlatform() -> str
    if platform.system() == "Windows"
        return "win"
    elseif platform.system() == "Darwin"
        return "darwin"
    elseif os.name == "posix"
        return "nix"
    else
        return os.name
    end
end

function cleanedFlatNotation(music_str::String) -> String
    return replace(music_str, r"([A-Ga-g])b", r"\1-")
end

Test.@test cleanedFlatNotation("Cb") == "C-"