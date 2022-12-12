# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         common/pathTools.py
# Purpose:      Utilities for paths
#
# Authors:      Michael Scott Asato Cuthbert
#               Christopher Ariza
#
# Copyright:    Copyright © 2009-2015 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

using FilePathsBase
using Test
using Sys

const StrOrPath = Union{String, Path}

function getSourceFilePath() -> PosixPath
    f = $@__FILE__
    parents(f)[-2]
end

function getMetadataCacheFilePath() -> PosixPath
    joinpath(getSourceFilePath(), "corpus", "_metadataCache")
end

function getCorpusFilePath() -> PosixPath
    joinpath(getSourceFilePath(), "corpus")
end

function getCorpusContentDirs() -> Vector{String}
    directoryName = getCorpusFilePath()
    result = []
    # dirs to exclude; all files will be retained
    excludedNames = (
        "license.txt",
        "_metadataCache",
        "__pycache__",
    )
    for filename in sort(collect(readdir(directoryName)))
        if endswith(filename, (".jl", ".py", ".pyc", ".pyo"))
            continue
        elseif startswith(filename, ".")
            continue
        elseif filename in excludedNames
            continue
        end
        push!(result, filename)
    end
    return sort(result)
end

Test.@test getCorpusContentDirs() == [
    "airdsAirs",
    "bach",
    "beach",
    "beethoven",
    "chopin",
    "ciconia",
    "corelli",
    "cpebach",
    "demos",
    "essenFolksong",
    "handel",
    "haydn",
    "joplin",
    "josquin",
    "leadSheet",
    "luca",
    "miscFolk",
    "monteverdi",
    "mozart",
    "nottingham-dataset",
    "oneills1850",
    "palestrina",
    "ryansMammoth",
    "schoenberg",
    "schubert",
    "schumann_clara",
    "schumann_robert",
    "theoryExercises",
    "trecento",
    "verdi",
    "weber",
]

function getRootFilePath() -> PosixPath
    fpMusic21 = getSourceFilePath()
    fpParent = parent(fpMusic21)
    # Do not assume will end in music21 -- people can put this anywhere they want
    return fpParent
end

function relativepath() -> StrOrPath
    if Sys.iswindows()
        return path
    else
        return relpath(path, start)
    end
end

function cleanpath(path: StrOrPath, returnPathlib::Union{Bool, Nothing}) -> StrOrPath

    if isinstance(path, pathlib.Path)
        path = str(path)
        if returnPathlib == Nothing
            returnPathlib = True
        end
    
    else if returnPathlib == Nothing
        returnPathlib = false
    path = os.path.expanduser(path)
    path = os.path.normpath(path)
    
    if !(absolute(path) == path)
        path = os.path.abspath(path)

    path = os.path.expandvars(path)
    if !returnPathlib
        return path
    else:
        return pathlib.Path(path)
    
end
