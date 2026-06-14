--[[
    Unit Tests for the Flags System (Main.lua)
    Tests: Flag creation, get/set, toggle, connect/disconnect, storage
]]

package.path = package.path .. ";./?.lua;./?/init.lua"

local lu = require("tests.lib.luaunit")
local Flags = require("tests.modules.flags")

TestFlags = {}

function TestFlags:setUp()
    Flags:Reset()
end

-- Test creating a flag with default value
function TestFlags:test_create_flag()
    local flag = Flags:Create("TestFlag", true)
    lu.assertNotNil(flag)
    lu.assertEquals(flag.Name, "TestFlag")
    lu.assertEquals(flag.Value, true)
end

-- Test creating a flag with number default
function TestFlags:test_create_flag_number()
    local flag = Flags:Create("NumFlag", 42)
    lu.assertEquals(flag:Get(), 42)
end

-- Test creating a flag with string default
function TestFlags:test_create_flag_string()
    local flag = Flags:Create("StrFlag", "hello")
    lu.assertEquals(flag:Get(), "hello")
end

-- Test creating a flag with nil default
function TestFlags:test_create_flag_nil()
    local flag = Flags:Create("NilFlag", nil)
    lu.assertNil(flag:Get())
end

-- Test that creating the same flag twice returns the same instance
function TestFlags:test_create_duplicate_returns_same()
    local flag1 = Flags:Create("DupFlag", "first")
    local flag2 = Flags:Create("DupFlag", "second")
    lu.assertEquals(flag1, flag2)
    lu.assertEquals(flag1:Get(), "first") -- original value preserved
end

-- Test Get method
function TestFlags:test_get()
    local flag = Flags:Create("GetFlag", 100)
    lu.assertEquals(flag:Get(), 100)
end

-- Test Set method
function TestFlags:test_set()
    local flag = Flags:Create("SetFlag", 10)
    flag:Set(20)
    lu.assertEquals(flag:Get(), 20)
end

-- Test Set with different types
function TestFlags:test_set_different_types()
    local flag = Flags:Create("TypeFlag", "initial")
    flag:Set(123)
    lu.assertEquals(flag:Get(), 123)
    flag:Set(true)
    lu.assertEquals(flag:Get(), true)
    flag:Set(nil)
    lu.assertNil(flag:Get())
end

-- Test Toggle method
function TestFlags:test_toggle_true_to_false()
    local flag = Flags:Create("ToggleFlag", true)
    flag:Toggle()
    lu.assertEquals(flag:Get(), false)
end

-- Test Toggle method false to true
function TestFlags:test_toggle_false_to_true()
    local flag = Flags:Create("ToggleFlag2", false)
    flag:Toggle()
    lu.assertEquals(flag:Get(), true)
end

-- Test Toggle twice returns to original
function TestFlags:test_toggle_twice()
    local flag = Flags:Create("ToggleFlag3", true)
    flag:Toggle()
    flag:Toggle()
    lu.assertEquals(flag:Get(), true)
end

-- Test Connect callback is called on Set
function TestFlags:test_connect_callback()
    local flag = Flags:Create("ConnFlag", "old")
    local received_new = nil
    local received_old = nil
    flag:Connect(function(newVal, oldVal)
        received_new = newVal
        received_old = oldVal
    end)
    flag:Set("new")
    lu.assertEquals(received_new, "new")
    lu.assertEquals(received_old, "old")
end

-- Test multiple callbacks are all called
function TestFlags:test_multiple_callbacks()
    local flag = Flags:Create("MultiCB", 0)
    local count = 0
    flag:Connect(function() count = count + 1 end)
    flag:Connect(function() count = count + 1 end)
    flag:Connect(function() count = count + 1 end)
    flag:Set(1)
    lu.assertEquals(count, 3)
end

-- Test Disconnect removes callback
function TestFlags:test_disconnect()
    local flag = Flags:Create("DisconnFlag", 0)
    local count = 0
    local conn = flag:Connect(function() count = count + 1 end)
    flag:Set(1)
    lu.assertEquals(count, 1)
    conn.Disconnect()
    flag:Set(2)
    lu.assertEquals(count, 1) -- should not have increased
end

-- Test Flags:Get retrieves by name
function TestFlags:test_flags_get()
    Flags:Create("NamedFlag", 42)
    local flag = Flags:Get("NamedFlag")
    lu.assertNotNil(flag)
    lu.assertEquals(flag:Get(), 42)
end

-- Test Flags:Get returns nil for non-existent
function TestFlags:test_flags_get_nonexistent()
    local flag = Flags:Get("NonExistent")
    lu.assertNil(flag)
end

-- Test Flags:Set changes value by name
function TestFlags:test_flags_set_by_name()
    Flags:Create("NameSet", 1)
    Flags:Set("NameSet", 99)
    lu.assertEquals(Flags:GetValue("NameSet"), 99)
end

-- Test Flags:Set does nothing for non-existent
function TestFlags:test_flags_set_nonexistent()
    -- Should not error
    Flags:Set("DoesNotExist", 42)
end

-- Test Flags:GetValue
function TestFlags:test_get_value()
    Flags:Create("ValFlag", "test_value")
    lu.assertEquals(Flags:GetValue("ValFlag"), "test_value")
end

-- Test Flags:GetValue returns nil for non-existent
function TestFlags:test_get_value_nonexistent()
    lu.assertNil(Flags:GetValue("Nope"))
end

-- Test Flags:Count
function TestFlags:test_count()
    lu.assertEquals(Flags:Count(), 0)
    Flags:Create("A", 1)
    lu.assertEquals(Flags:Count(), 1)
    Flags:Create("B", 2)
    lu.assertEquals(Flags:Count(), 2)
    Flags:Create("C", 3)
    lu.assertEquals(Flags:Count(), 3)
end

-- Test that callback errors don't crash Set
function TestFlags:test_callback_error_doesnt_crash()
    local flag = Flags:Create("ErrCB", 0)
    flag:Connect(function() error("intentional error") end)
    -- Should not throw
    flag:Set(1)
    lu.assertEquals(flag:Get(), 1)
end

-- Test Connect after Toggle calls callback
function TestFlags:test_toggle_triggers_callback()
    local flag = Flags:Create("ToggleCB", true)
    local called = false
    flag:Connect(function(new, old)
        called = true
        lu.assertEquals(new, false)
        lu.assertEquals(old, true)
    end)
    flag:Toggle()
    lu.assertTrue(called)
end

os.exit(lu.LuaUnit.run())
