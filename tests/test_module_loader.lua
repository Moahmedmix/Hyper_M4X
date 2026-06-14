--[[
    Unit Tests for the ModuleLoader System (Main.lua)
    Tests: Loading modules, retry logic, error handling, stats tracking
]]

package.path = package.path .. ";./?.lua;./?/init.lua"

local lu = require("tests.lib.luaunit")
local Logger = require("tests.modules.logger")
local ModuleLoader = require("tests.modules.module_loader")

TestModuleLoader = {}

function TestModuleLoader:setUp()
    ModuleLoader:Reset()
    Logger:Reset()
    ModuleLoader:SetFetchFunction(nil)
end

-- Test successful module load
function TestModuleLoader:test_successful_load()
    ModuleLoader:SetFetchFunction(function(url)
        return "return { hello = 'world' }"
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "TestMod", true)
    lu.assertNotNil(result)
    lu.assertEquals(result.hello, "world")
end

-- Test stats after successful load
function TestModuleLoader:test_stats_after_success()
    ModuleLoader:SetFetchFunction(function(url) return "return 42" end)
    ModuleLoader:LoadFromURL("http://test.com/mod.lua", "Mod1", true)
    lu.assertEquals(ModuleLoader.Stats.Total, 1)
    lu.assertEquals(ModuleLoader.Stats.Loaded, 1)
    lu.assertEquals(ModuleLoader.Stats.Failed, 0)
    lu.assertEquals(ModuleLoader.Stats.Skipped, 0)
end

-- Test network failure on required module
function TestModuleLoader:test_network_failure_required()
    ModuleLoader:SetFetchFunction(function(url)
        error("Network error")
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "FailMod", true, 2)
    lu.assertNil(result)
    lu.assertEquals(ModuleLoader.Stats.Failed, 1)
    lu.assertEquals(#ModuleLoader.Failed, 1)
    lu.assertEquals(ModuleLoader.Failed[1].Name, "FailMod")
    lu.assertEquals(ModuleLoader.Failed[1].Reason, "Network")
end

-- Test network failure on optional module (should skip, not fail)
function TestModuleLoader:test_network_failure_optional()
    ModuleLoader:SetFetchFunction(function(url)
        error("Network error")
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "OptMod", false, 2)
    lu.assertNil(result)
    lu.assertEquals(ModuleLoader.Stats.Skipped, 1)
    lu.assertEquals(ModuleLoader.Stats.Failed, 0)
    lu.assertEquals(#ModuleLoader.Skipped, 1)
    lu.assertEquals(ModuleLoader.Skipped[1].Reason, "Network")
end

-- Test syntax error on required module
function TestModuleLoader:test_syntax_error_required()
    ModuleLoader:SetFetchFunction(function(url)
        return "this is not valid lua }{]["
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "BadSyntax", true)
    lu.assertNil(result)
    lu.assertEquals(ModuleLoader.Stats.Failed, 1)
    lu.assertEquals(ModuleLoader.Failed[1].Reason, "Syntax")
end

-- Test syntax error on optional module
function TestModuleLoader:test_syntax_error_optional()
    ModuleLoader:SetFetchFunction(function(url)
        return "this is not valid lua }{]["
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "BadSyntax", false)
    lu.assertNil(result)
    lu.assertEquals(ModuleLoader.Stats.Skipped, 1)
    lu.assertEquals(ModuleLoader.Skipped[1].Reason, "Syntax")
end

-- Test runtime error on required module
function TestModuleLoader:test_runtime_error_required()
    ModuleLoader:SetFetchFunction(function(url)
        return "error('runtime failure')"
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "RuntimeFail", true)
    lu.assertNil(result)
    lu.assertEquals(ModuleLoader.Stats.Failed, 1)
    lu.assertEquals(ModuleLoader.Failed[1].Reason, "Runtime")
end

-- Test runtime error on optional module
function TestModuleLoader:test_runtime_error_optional()
    ModuleLoader:SetFetchFunction(function(url)
        return "error('runtime failure')"
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "RuntimeFail", false)
    lu.assertNil(result)
    lu.assertEquals(ModuleLoader.Stats.Skipped, 1)
    lu.assertEquals(ModuleLoader.Skipped[1].Reason, "Runtime")
end

-- Test retry logic counts (retries before failing)
function TestModuleLoader:test_retry_logic()
    local attempt_count = 0
    ModuleLoader:SetFetchFunction(function(url)
        attempt_count = attempt_count + 1
        error("fail")
    end)
    ModuleLoader:LoadFromURL("http://test.com/mod.lua", "RetryMod", true)
    -- Should attempt MaxRetries + 1 times (initial + retries)
    lu.assertEquals(attempt_count, ModuleLoader.MaxRetries + 1)
end

-- Test retry succeeds on second attempt
function TestModuleLoader:test_retry_succeeds()
    local attempt_count = 0
    ModuleLoader:SetFetchFunction(function(url)
        attempt_count = attempt_count + 1
        if attempt_count == 1 then
            error("temporary failure")
        end
        return "return 'recovered'"
    end)
    local result = ModuleLoader:LoadFromURL("http://test.com/mod.lua", "RecoverMod", true)
    lu.assertEquals(result, "recovered")
    lu.assertEquals(ModuleLoader.Stats.Loaded, 1)
end

-- Test multiple loads increment Total correctly
function TestModuleLoader:test_total_stats()
    ModuleLoader:SetFetchFunction(function(url) return "return true" end)
    ModuleLoader:LoadFromURL("http://test.com/a.lua", "A", true)
    ModuleLoader:LoadFromURL("http://test.com/b.lua", "B", false)
    ModuleLoader:LoadFromURL("http://test.com/c.lua", "C", true)
    lu.assertEquals(ModuleLoader.Stats.Loaded, 3)
    -- Total counts each attempt including retries, so for direct successes it's 3
    lu.assertTrue(ModuleLoader.Stats.Total >= 3)
end

-- Test LoadFromRepo constructs correct URL
function TestModuleLoader:test_load_from_repo_url()
    local captured_url = nil
    ModuleLoader:SetFetchFunction(function(url)
        captured_url = url
        return "return {}"
    end)
    ModuleLoader:LoadFromRepo("Features/Aimbot/FOV.lua", true)
    lu.assertNotNil(captured_url)
    lu.assertStrContains(captured_url, "Features/Aimbot/FOV.lua")
    lu.assertStrContains(captured_url, "raw.githubusercontent.com")
end

-- Test LoadFromRepo extracts module name from path
function TestModuleLoader:test_load_from_repo_name()
    ModuleLoader:SetFetchFunction(function(url) return "return {}" end)
    ModuleLoader:LoadFromRepo("Features/Movement/Speed.lua", true)
    lu.assertEquals(ModuleLoader.Loaded[1].Name, "Speed")
end

-- Test Loaded list stores modules correctly
function TestModuleLoader:test_loaded_list()
    ModuleLoader:SetFetchFunction(function(url) return "return { test = true }" end)
    ModuleLoader:LoadFromURL("http://x.com/a.lua", "ModA", true)
    lu.assertEquals(#ModuleLoader.Loaded, 1)
    lu.assertEquals(ModuleLoader.Loaded[1].Name, "ModA")
    lu.assertTrue(ModuleLoader.Loaded[1].Module.test)
end

-- Test Reset clears all state
function TestModuleLoader:test_reset()
    ModuleLoader:SetFetchFunction(function(url) return "return {}" end)
    ModuleLoader:LoadFromURL("http://x.com/a.lua", "A", true)
    ModuleLoader:Reset()
    lu.assertEquals(#ModuleLoader.Loaded, 0)
    lu.assertEquals(#ModuleLoader.Failed, 0)
    lu.assertEquals(#ModuleLoader.Skipped, 0)
    lu.assertEquals(ModuleLoader.Stats.Total, 0)
    lu.assertEquals(ModuleLoader.Stats.Loaded, 0)
end

os.exit(lu.LuaUnit.run())
