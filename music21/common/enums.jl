# -*- coding: utf-8 -*-
# ------------------------------------------------------------------------------
# Name:         common/enums.py
# Purpose:      Music21 Enumerations
#
# Authors:      Michael Scott Asato Cuthbert
#
# Copyright:    Copyright © 2021-2022 Michael Scott Asato Cuthbert
# License:      BSD, see license.txt
# ------------------------------------------------------------------------------

@enum ElementSearch begin
    BEFORE = "getElementBefore"
    AFTER = "getElementAfter"
    AT_OR_BEFORE = "getElementAtOrBefore"
    AT_OR_AFTER = "getElementAtOrAfter"
    BEFORE_OFFSET = "getElementBeforeOffset"
    AFTER_OFFSET = "getElementAfterOffset"
    AT_OR_BEFORE_OFFSET = "getElementAtOrBeforeOffset"
    AT_OR_AFTER_OFFSET = "getElementAtOrAfterOffset"
    BEFORE_NOT_SELF = "getElementBeforeNotSelf"
    AFTER_NOT_SELF = "getElementAfterNotSelf"
    ALL = "all"
end

@enum OffsetSpecial begin
    AT_END = "highestTime"
    LOWEST_OFFSET = "lowestOffset"
    HIGHEST_OFFSET = "highestOffset"
end
Test.@test OffsetSpecial.AT_END == "highestTime"
Test.@test OffsetSpecial.LOWEST_OFFSET == "lowestOffset"
Test.@test OffsetSpecial.HIGHEST_OFFSET == "highestOffset"
Test.@test "crazyOffset" in OffsetSpecial == false
Test.@test 6.0 in OffsetSpecial == false
Test.@test string(OffsetSpecial.AT_END) == "highestTime"


@enum GatherSpanners begin
    ALL = true
    NONE = false
    COMPLETE_ONLY = "completeOnly"
end

@enum MeterDivision begin
    FAST = "fast"
    SLOW = "slow"
    NONE = "none"
end