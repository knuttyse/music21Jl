# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         defaults.py
# Purpose:      Storage for user environment settings and defaults
#
# Authors:      Christopher Ariza
#               Michael Scott Asato Cuthbert
#
# Copyright:    Copyright © 2009-2010 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

# note: this module should not import any higher level modules
const StepName = Union{'C', 'D', 'E', 'F', 'G', 'A', 'B'}

title = "Music21 Fragment"
author = "Music21"
software = "music21 v." + _version.__version__  # used in xml encoding source software
musicxmlVersion = "4.0"

meterNumerator = 4
meterDenominator = "quarter"
meterDenominatorBeatType = 4  # musicxml representation

limitOffsetDenominator = 65535  # > CD track level precision.


pitchStep: StepName = "C"
pitchOctave = 4

partGroup = "Part Group"
partGroupAbbreviation = "PG"

durationType = "quarter"

instrumentName: str = ""
partName: str = ""

keyFifths = 0
keyMode = "major"


clefSign = "G"
clefLine = 2

noteheadUnpitched = "square"
divisionsPerQuarter = 32 * 3 * 3 * 5 * 7  # 10080
ticksPerQuarter = 1024
ticksAtStart = 1024
quantizationQuarterLengthDivisors = (4, 3)
scalingMillimeters = 7
scalingTenths = 40
ipythonImageDpi = 200  # retina...
multiMeasureRestUseSymbols = True
multiMeasureRestMaxSymbols = 11
minIdNumberToConsiderMemoryLocation = 100_000_001