--[[
    Unit Tests for the FeatureInitializer System (Main.lua)
    Tests: Feature initialization, nil handling, error handling, tracking
]]

package.path = package.path .. ";./?.lua;./?/init.lua"

local lu = require("tests.lib.luaunit")
local Logger = require("tests.modules.logger")
local FeatureInitializer = require("tests.modules.feature_initializer")

TestFeatureInitializer = {}

function TestFeatureInitializer:setUp()
    FeatureInitializer:Reset()
    Logger:Reset()
end

-- Test nil module is skipped
function TestFeatureInitializer:test_nil_module_skipped()
    local result = FeatureInitializer:InitFeature(nil, {}, {}, {}, "NilModule")
    lu.assertFalse(result)
    lu.assertEquals(#FeatureInitializer.Skipped, 1)
    lu.assertEquals(FeatureInitializer.Skipped[1].Name, "NilModule")
    lu.assertEquals(FeatureInitializer.Skipped[1].Reason, "Module is nil")
end

-- Test module without Init function is skipped
function TestFeatureInitializer:test_no_init_function_skipped()
    local module = { SomeMethod = function() end }
    local result = FeatureInitializer:InitFeature(module, {}, {}, {}, "NoInitMod")
    lu.assertFalse(result)
    lu.assertEquals(#FeatureInitializer.Skipped, 1)
    lu.assertEquals(FeatureInitializer.Skipped[1].Reason, "No Init function")
end

-- Test module with Init that is not a function is skipped
function TestFeatureInitializer:test_init_not_function_skipped()
    local module = { Init = "not a function" }
    local result = FeatureInitializer:InitFeature(module, {}, {}, {}, "BadInitMod")
    lu.assertFalse(result)
    lu.assertEquals(#FeatureInitializer.Skipped, 1)
    lu.assertEquals(FeatureInitializer.Skipped[1].Reason, "No Init function")
end

-- Test successful initialization
function TestFeatureInitializer:test_successful_init()
    local initialized = false
    local module = {
        Init = function(self, tab, library, flags)
            initialized = true
        end
    }
    local result = FeatureInitializer:InitFeature(module, {}, {}, {}, "GoodModule")
    lu.assertTrue(result)
    lu.assertTrue(initialized)
    lu.assertEquals(#FeatureInitializer.Initialized, 1)
    lu.assertEquals(FeatureInitializer.Initialized[1].Name, "GoodModule")
end

-- Test Init receives correct parameters
function TestFeatureInitializer:test_init_receives_params()
    local recv_tab, recv_lib, recv_flags = nil, nil, nil
    local module = {
        Init = function(self, tab, library, flags)
            recv_tab = tab
            recv_lib = library
            recv_flags = flags
        end
    }
    local tab = { id = "tab1" }
    local lib = { id = "lib1" }
    local flags = { id = "flags1" }
    FeatureInitializer:InitFeature(module, tab, lib, flags, "ParamMod")
    lu.assertEquals(recv_tab.id, "tab1")
    lu.assertEquals(recv_lib.id, "lib1")
    lu.assertEquals(recv_flags.id, "flags1")
end

-- Test Init that throws error is caught
function TestFeatureInitializer:test_init_error_caught()
    local module = {
        Init = function(self, tab, library, flags)
            error("Init crashed!")
        end
    }
    local result = FeatureInitializer:InitFeature(module, {}, {}, {}, "CrashMod")
    lu.assertFalse(result)
    lu.assertEquals(#FeatureInitializer.Failed, 1)
    lu.assertEquals(FeatureInitializer.Failed[1].Name, "CrashMod")
    lu.assertStrContains(FeatureInitializer.Failed[1].Reason, "Init crashed!")
end

-- Test multiple features tracked correctly
function TestFeatureInitializer:test_multiple_features()
    local goodMod = { Init = function(self) end }
    local badMod = { Init = function(self) error("fail") end }
    local nilMod = nil

    FeatureInitializer:InitFeature(goodMod, {}, {}, {}, "Good1")
    FeatureInitializer:InitFeature(badMod, {}, {}, {}, "Bad1")
    FeatureInitializer:InitFeature(nilMod, {}, {}, {}, "Nil1")
    FeatureInitializer:InitFeature(goodMod, {}, {}, {}, "Good2")

    lu.assertEquals(#FeatureInitializer.Initialized, 2)
    lu.assertEquals(#FeatureInitializer.Failed, 1)
    lu.assertEquals(#FeatureInitializer.Skipped, 1)
end

-- Test Reset clears all state
function TestFeatureInitializer:test_reset()
    local module = { Init = function(self) end }
    FeatureInitializer:InitFeature(module, {}, {}, {}, "M1")
    FeatureInitializer:Reset()
    lu.assertEquals(#FeatureInitializer.Initialized, 0)
    lu.assertEquals(#FeatureInitializer.Failed, 0)
    lu.assertEquals(#FeatureInitializer.Skipped, 0)
end

-- Test module stored in Initialized list
function TestFeatureInitializer:test_module_stored()
    local module = { Init = function(self) end, CustomField = "hello" }
    FeatureInitializer:InitFeature(module, {}, {}, {}, "StoredMod")
    lu.assertEquals(FeatureInitializer.Initialized[1].Module.CustomField, "hello")
end

-- Test empty table module (no Init) is skipped
function TestFeatureInitializer:test_empty_table_skipped()
    local result = FeatureInitializer:InitFeature({}, {}, {}, {}, "EmptyMod")
    lu.assertFalse(result)
    lu.assertEquals(#FeatureInitializer.Skipped, 1)
end

os.exit(lu.LuaUnit.run())
