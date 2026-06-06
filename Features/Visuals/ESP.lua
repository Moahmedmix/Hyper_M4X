--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - ESP SYSTEM - v5 FINAL                   ║
    ║    10 Box Styles + Chams + Full Customization                ║
    ║              By M4X | EVA | AMAL                            ║
    ╚══════════════════════════════════════════════════════════════╝
--]]

local ESP = {}
ESP.__index = ESP

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Camera = workspace.CurrentCamera
local LocalPlayer = Players.LocalPlayer

ESP.Settings = {
    Enabled = false, MaxDist = 3000, TeamCheck = false, TeamColor = false, Rainbow = false, VisCheck = false, WallCheck = true,
    BoxStyle = "Corner", BoxColor = Color3.fromRGB(255, 255, 255), BoxThickness = 2, BoxFill = false, BoxFillColor = Color3.fromRGB(255, 255, 255), BoxGlow = false, CornerLen = 22,
    Chams = false, ChamsFillColor = Color3.fromRGB(255, 0, 0), ChamsFillTransparency = 0.5,
    Name = true, NameColor = Color3.fromRGB(255, 255, 255), NameSize = 13, NameOutline = true,
    Dist = true, DistColor = Color3.fromRGB(180, 180, 180), DistSize = 12, DistBrackets = true,
    HP = true, HPPos = "Left", HPThick = 3, HPBG = Color3.fromRGB(20, 20, 20), HPText = true, Armor = false,
    Tracer = false, TracerColor = Color3.fromRGB(255, 255, 255), TracerOrigin = "Bottom", TracerThick = 1,
    Snap = false, SnapColor = Color3.fromRGB(255, 255, 255), SnapThick = 1,
    Weapon = false, WeaponColor = Color3.fromRGB(255, 200, 50),
    Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255), SkeletonThick = 1,
    HeadDot = false, HeadDotColor = Color3.fromRGB(255, 255, 255), HeadDotSize = 4,
    LookDir = false, Velocity = false, OffScreen = false, InfoPanel = false, Rank = false, Status = false,
}

ESP.Boxes = {}
ESP.Conn = nil
ESP.RainbowHue = 0

local RootNames = {"HumanoidRootPart","UpperTorso","Torso","LowerTorso","RootPart","Root","Chest","Body","Base","Main","Center","Core","Hip","Waist","Spine","Pelvis"}
local HeadNames = {"Head","head","HEAD","Hat","Helmet","Face","Skull","Cranium","Brain","Top"}
local SkeletonBones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},
    {"LeftLowerLeg","LeftFoot"},{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

function ESP:FindRoot(c)
    for _,n in ipairs(RootNames) do local p=c:FindFirstChild(n) if p and p:IsA("BasePart") then return p end end
    for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") and p.Name~="Head" then return p end end
    return nil
end

function ESP:FindHead(c)
    for _,n in ipairs(HeadNames) do local p=c:FindFirstChild(n) if p and p:IsA("BasePart") then return p end end
    local hi,hy=nil,-math.huge
    for _,p in ipairs(c:GetChildren()) do if p:IsA("BasePart") then local y=p.Position.Y if y>hy then hy=y hi=p end end end
    return hi
end

function ESP:GetColor(p)
    if ESP.Settings.Rainbow then ESP.RainbowHue=(ESP.RainbowHue+0.003)%1 return Color3.fromHSV(ESP.RainbowHue,1,1) end
    if ESP.Settings.TeamColor and p.Team and LocalPlayer.Team then
        if p.Team==LocalPlayer.Team then return Color3.fromRGB(50,255,50) end
        return Color3.fromRGB(255,50,50)
    end
    return ESP.Settings.BoxColor
end

function ESP:IsOnScreen(sp)
    local vp=Camera.ViewportSize
    return sp.Z>0 and sp.X>=-100 and sp.X<=vp.X+100 and sp.Y>=-100 and sp.Y<=vp.Y+100
end

function ESP:CreatePlayer(p)
    local b={}
    for i=1,50 do b[i]=Drawing.new("Line") b[i].Visible=false end
    b.Name=Drawing.new("Text") b.Name.Center=true b.Name.Visible=false
    b.Dist=Drawing.new("Text") b.Dist.Center=true b.Dist.Visible=false
    b.Weapon=Drawing.new("Text") b.Weapon.Center=true b.Weapon.Visible=false
    b.Info=Drawing.new("Text") b.Info.Center=false b.Info.Visible=false
    b.Rank=Drawing.new("Text") b.Rank.Center=true b.Rank.Visible=false
    b.Status=Drawing.new("Text") b.Status.Center=true b.Status.Visible=false
    b.HPText=Drawing.new("Text") b.HPText.Center=true b.HPText.Visible=false
    b.ArmorText=Drawing.new("Text") b.ArmorText.Center=true b.ArmorText.Visible=false
    b.HPBg=Drawing.new("Square") b.HPBg.Filled=true b.HPBg.Visible=false
    b.HPFill=Drawing.new("Square") b.HPFill.Filled=true b.HPFill.Visible=false
    b.ArmorBg=Drawing.new("Square") b.ArmorBg.Filled=true b.ArmorBg.Visible=false
    b.ArmorFill=Drawing.new("Square") b.ArmorFill.Filled=true b.ArmorFill.Visible=false
    b.BoxFill=Drawing.new("Square") b.BoxFill.Filled=true b.BoxFill.Visible=false
    b.HeadDot=Drawing.new("Circle") b.HeadDot.Visible=false
    b.Tracer=Drawing.new("Line") b.Tracer.Visible=false
    b.Snap=Drawing.new("Line") b.Snap.Visible=false
    b.LookDir=Drawing.new("Line") b.LookDir.Visible=false
    b.Velocity=Drawing.new("Line") b.Velocity.Visible=false
    b.OffScreenArrow=Drawing.new("Triangle") b.OffScreenArrow.Visible=false
    b.OffScreenDist=Drawing.new("Text") b.OffScreenDist.Center=true b.OffScreenDist.Visible=false
    b.Chams=nil
    b.Glow={}
    for i=1,4 do b.Glow[i]=Drawing.new("Line") b.Glow[i].Visible=false end
    ESP.Boxes[p]=b
end

function ESP:HidePlayerDrawings(p)
    local b=ESP.Boxes[p] if not b then return end
    for i=1,50 do if b[i] and b[i].Remove then b[i].Visible=false end end
    local texts={"Name","Dist","Weapon","Info","Rank","Status","HPText","ArmorText","OffScreenDist"}
    for _,n in ipairs(texts) do if b[n] and b[n].Remove then b[n].Visible=false end end
    local squares={"HPBg","HPFill","ArmorBg","ArmorFill","BoxFill"}
    for _,n in ipairs(squares) do if b[n] and b[n].Remove then b[n].Visible=false end end
    if b.HeadDot and b.HeadDot.Remove then b.HeadDot.Visible=false end
    local lines={"Tracer","Snap","LookDir","Velocity"}
    for _,n in ipairs(lines) do if b[n] and b[n].Remove then b[n].Visible=false end end
    if b.OffScreenArrow and b.OffScreenArrow.Remove then b.OffScreenArrow.Visible=false end
    for i=1,4 do if b.Glow[i] and b.Glow[i].Remove then b.Glow[i].Visible=false end end
    if b.Chams then b.Chams:Destroy() b.Chams=nil end
end

function ESP:CleanPlayer(p)
    if ESP.Boxes[p] then for _,v in pairs(ESP.Boxes[p]) do if type(v)=="table" and v.Remove then v.Visible=false v:Remove() end end ESP.Boxes[p]=nil end
end

function ESP:CleanAll()
    for p in pairs(ESP.Boxes) do ESP:CleanPlayer(p) end
    ESP.Boxes={}
end

-- =============================================
-- BOX DRAWING
-- =============================================
function ESP:DrawBox(b, dims, color, thick, style)
    local x,y,w,h=dims.x,dims.y,dims.w,dims.h
    local cl=math.clamp(w*0.25,8,ESP.Settings.CornerLen)

    if style=="Corner" then
        b[1].From,b[1].To=Vector2.new(x,y),Vector2.new(x+cl,y) b[1].Color,b[1].Thickness,b[1].Visible=color,thick,true
        b[2].From,b[2].To=Vector2.new(x,y),Vector2.new(x,y+cl) b[2].Color,b[2].Thickness,b[2].Visible=color,thick,true
        b[3].From,b[3].To=Vector2.new(x+w-cl,y),Vector2.new(x+w,y) b[3].Color,b[3].Thickness,b[3].Visible=color,thick,true
        b[4].From,b[4].To=Vector2.new(x+w,y),Vector2.new(x+w,y+cl) b[4].Color,b[4].Thickness,b[4].Visible=color,thick,true
        b[5].From,b[5].To=Vector2.new(x,y+h),Vector2.new(x+cl,y+h) b[5].Color,b[5].Thickness,b[5].Visible=color,thick,true
        b[6].From,b[6].To=Vector2.new(x,y+h-cl),Vector2.new(x,y+h) b[6].Color,b[6].Thickness,b[6].Visible=color,thick,true
        b[7].From,b[7].To=Vector2.new(x+w-cl,y+h),Vector2.new(x+w,y+h) b[7].Color,b[7].Thickness,b[7].Visible=color,thick,true
        b[8].From,b[8].To=Vector2.new(x+w,y+h-cl),Vector2.new(x+w,y+h) b[8].Color,b[8].Thickness,b[8].Visible=color,thick,true
    elseif style=="Full" then
        b[1].From,b[1].To=Vector2.new(x,y),Vector2.new(x+w,y) b[1].Color,b[1].Thickness,b[1].Visible=color,thick,true
        b[2].From,b[2].To=Vector2.new(x+w,y),Vector2.new(x+w,y+h) b[2].Color,b[2].Thickness,b[2].Visible=color,thick,true
        b[3].From,b[3].To=Vector2.new(x+w,y+h),Vector2.new(x,y+h) b[3].Color,b[3].Thickness,b[3].Visible=color,thick,true
        b[4].From,b[4].To=Vector2.new(x,y+h),Vector2.new(x,y) b[4].Color,b[4].Thickness,b[4].Visible=color,thick,true
        if ESP.Settings.BoxFill then
            b.BoxFill.Size=Vector2.new(w,h) b.BoxFill.Position=Vector2.new(x,y) b.BoxFill.Color=ESP.Settings.BoxFillColor b.BoxFill.Transparency=0.8 b.BoxFill.Visible=true
        else b.BoxFill.Visible=false end
    elseif style=="Circle" then
        local cx,cy=dims.centerX,dims.centerY
        local r=math.min(w,h)/2
        local seg=32
        for i=1,seg do
            local a1=(i-1)*2*math.pi/seg local a2=i*2*math.pi/seg
            b[i].From=Vector2.new(cx+math.cos(a1)*r,cy+math.sin(a1)*r)
            b[i].To=Vector2.new(cx+math.cos(a2)*r,cy+math.sin(a2)*r)
            b[i].Color,b[i].Thickness,b[i].Visible=color,thick,true
        end
    elseif style=="Diamond" then
        local cx,cy=dims.centerX,dims.centerY local s=math.min(w,h)/2
        b[1].From,b[1].To=Vector2.new(cx,cy-s),Vector2.new(cx+s,cy) b[1].Color,b[1].Thickness,b[1].Visible=color,thick,true
        b[2].From,b[2].To=Vector2.new(cx+s,cy),Vector2.new(cx,cy+s) b[2].Color,b[2].Thickness,b[2].Visible=color,thick,true
        b[3].From,b[3].To=Vector2.new(cx,cy+s),Vector2.new(cx-s,cy) b[3].Color,b[3].Thickness,b[3].Visible=color,thick,true
        b[4].From,b[4].To=Vector2.new(cx-s,cy),Vector2.new(cx,cy-s) b[4].Color,b[4].Thickness,b[4].Visible=color,thick,true
    elseif style=="Crosshair" then
        local cx,cy=dims.centerX,dims.centerY local s=15 local g=5
        b[1].From,b[1].To=Vector2.new(cx-s-g,cy),Vector2.new(cx-g,cy) b[1].Color,b[1].Thickness,b[1].Visible=color,thick,true
        b[2].From,b[2].To=Vector2.new(cx+g,cy),Vector2.new(cx+s+g,cy) b[2].Color,b[2].Thickness,b[2].Visible=color,thick,true
        b[3].From,b[3].To=Vector2.new(cx,cy-s-g),Vector2.new(cx,cy-g) b[3].Color,b[3].Thickness,b[3].Visible=color,thick,true
        b[4].From,b[4].To=Vector2.new(cx,cy+g),Vector2.new(cx,cy+s+g) b[4].Color,b[4].Thickness,b[4].Visible=color,thick,true
    end
end

function ESP:Update()
    local mt=LocalPlayer.Team local cp=Camera.CFrame.Position local vp=Camera.ViewportSize local cx,cy=vp.X/2,vp.Y local proc={}

    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then ESP:HidePlayerDrawings(p) continue end
        if ESP.Settings.TeamCheck and p.Team==mt then ESP:HidePlayerDrawings(p) continue end

        local c=p.Character
        if not c then ESP:HidePlayerDrawings(p) continue end

        local h=ESP:FindHead(c) local r=ESP:FindRoot(c) local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not r then ESP:HidePlayerDrawings(p) continue end

        local rp=r.Position local dist=(cp-rp).Magnitude
        if dist>ESP.Settings.MaxDist then ESP:HidePlayerDrawings(p) continue end

        local rsp=Camera:WorldToViewportPoint(rp)
        local hsp=Camera:WorldToViewportPoint(h.Position+Vector3.new(0,0.5,0))
        local lsp=Camera:WorldToViewportPoint(rp-Vector3.new(0,3.5,0))
        if not ESP:IsOnScreen(rsp) then ESP:HidePlayerDrawings(p) continue end

        local bh=math.abs(hsp.Y-lsp.Y) local bw=bh*0.5 local x=rsp.X-bw/2 local y=hsp.Y

        if not ESP.Boxes[p] then ESP:CreatePlayer(p) end
        local b=ESP.Boxes[p]

        for i=1,50 do if b[i] and b[i].Remove then b[i].Visible=false end end

        local color=ESP:GetColor(p)
        local dims={x=x,y=y,w=bw,h=bh,centerX=rsp.X,centerY=rsp.Y}

        ESP:DrawBox(b,dims,color,ESP.Settings.BoxThickness,ESP.Settings.BoxStyle)

        if ESP.Settings.BoxGlow then
            local gt=ESP.Settings.BoxThickness+3
            b.Glow[1].From,b.Glow[1].To=Vector2.new(x-3,y-3),Vector2.new(x+bw+3,y-3) b.Glow[1].Color,b.Glow[1].Thickness,b.Glow[1].Visible,b.Glow[1].Transparency=color,gt,true,0.6
            b.Glow[2].From,b.Glow[2].To=Vector2.new(x+bw+3,y-3),Vector2.new(x+bw+3,y+bh+3) b.Glow[2].Color,b.Glow[2].Thickness,b.Glow[2].Visible,b.Glow[2].Transparency=color,gt,true,0.6
            b.Glow[3].From,b.Glow[3].To=Vector2.new(x+bw+3,y+bh+3),Vector2.new(x-3,y+bh+3) b.Glow[3].Color,b.Glow[3].Thickness,b.Glow[3].Visible,b.Glow[3].Transparency=color,gt,true,0.6
            b.Glow[4].From,b.Glow[4].To=Vector2.new(x-3,y+bh+3),Vector2.new(x-3,y-3) b.Glow[4].Color,b.Glow[4].Thickness,b.Glow[4].Visible,b.Glow[4].Transparency=color,gt,true,0.6
        else for i=1,4 do b.Glow[i].Visible=false end end

        if ESP.Settings.Chams then
            if not b.Chams then b.Chams=Instance.new("Highlight") b.Chams.Name="ESPChams" b.Chams.Parent=c end
            b.Chams.FillColor=ESP.Settings.ChamsFillColor b.Chams.FillTransparency=ESP.Settings.ChamsFillTransparency b.Chams.Enabled=true
        elseif b.Chams then b.Chams:Destroy() b.Chams=nil end

        if ESP.Settings.Name then
            b.Name.Text=p.DisplayName b.Name.Color=ESP.Settings.NameColor b.Name.Size=ESP.Settings.NameSize
            b.Name.Position=Vector2.new(rsp.X,y-16) b.Name.Visible=true
        else b.Name.Visible=false end

        if ESP.Settings.Dist then
            b.Dist.Text=ESP.Settings.DistBrackets and"["..math.floor(dist).."m]"or math.floor(dist).."m"
            b.Dist.Color=ESP.Settings.DistColor b.Dist.Size=ESP.Settings.DistSize
            b.Dist.Position=Vector2.new(rsp.X,y+bh+14) b.Dist.Visible=true
        else b.Dist.Visible=false end

        if ESP.Settings.HP and hum then
            local pct=math.clamp(hum.Health/hum.MaxHealth,0,1)
            local hc=pct>0.5 and Color3.fromRGB(50,200,50)or pct>0.25 and Color3.fromRGB(255,170,0)or Color3.fromRGB(255,50,50)
            local bw2=ESP.Settings.HPThick
            local hpx=ESP.Settings.HPPos=="Left"and x-bw2-4 or x+bw+4
            b.HPBg.Size,b.HPBg.Position=Vector2.new(bw2,bh),Vector2.new(hpx,y)
            b.HPBg.Color,b.HPBg.Visible=ESP.Settings.HPBG,true
            b.HPFill.Size,b.HPFill.Position=Vector2.new(bw2,bh*pct),Vector2.new(hpx,y+bh*(1-pct))
            b.HPFill.Color,b.HPFill.Visible=hc,true
        else b.HPBg.Visible=false b.HPFill.Visible=false end

        if ESP.Settings.Tracer then
            local sx=cx local sy=ESP.Settings.TracerOrigin=="Bottom"and cy or ESP.Settings.TracerOrigin=="Top"and 0 or cy/2
            b.Tracer.From,b.Tracer.To=Vector2.new(sx,sy),Vector2.new(rsp.X,rsp.Y)
            b.Tracer.Color,b.Tracer.Thickness,b.Tracer.Visible=ESP.Settings.TracerColor,ESP.Settings.TracerThick,true
        else b.Tracer.Visible=false end

        if ESP.Settings.Snap then
            b.Snap.From,b.Snap.To=Vector2.new(cx,cy),Vector2.new(rsp.X,rsp.Y)
            b.Snap.Color,b.Snap.Thickness,b.Snap.Visible=ESP.Settings.SnapColor,ESP.Settings.SnapThick,true
        else b.Snap.Visible=false end

        if ESP.Settings.Weapon then
            local wep=nil
            for _,tool in ipairs(c:GetChildren()) do if tool:IsA("Tool")and tool:FindFirstChild("Handle")then wep=tool.Name break end end
            if wep then b.Weapon.Text="["..wep.."]" b.Weapon.Color=ESP.Settings.WeaponColor b.Weapon.Size=11 b.Weapon.Position=Vector2.new(rsp.X,y+bh+28) b.Weapon.Visible=true end
        else b.Weapon.Visible=false end

        if ESP.Settings.Skeleton then
            local si=20
            for _,bone in ipairs(SkeletonBones) do
                local p1=c:FindFirstChild(bone[1]) local p2=c:FindFirstChild(bone[2])
                if p1 and p2 then
                    local sp1=Camera:WorldToViewportPoint(p1.Position) local sp2=Camera:WorldToViewportPoint(p2.Position)
                    if ESP:IsOnScreen(sp1) and ESP:IsOnScreen(sp2) then
                        b[si].From,b[si].To=Vector2.new(sp1.X,sp1.Y),Vector2.new(sp2.X,sp2.Y)
                        b[si].Color,b[si].Thickness,b[si].Visible=ESP.Settings.SkeletonColor,ESP.Settings.SkeletonThick,true
                        si=si+1
                    end
                end
            end
        end

        if ESP.Settings.HeadDot then
            local hcsp=Camera:WorldToViewportPoint(h.Position)
            if ESP:IsOnScreen(hcsp) then
                b.HeadDot.Position=Vector2.new(hcsp.X,hcsp.Y) b.HeadDot.Radius=ESP.Settings.HeadDotSize
                b.HeadDot.Color=ESP.Settings.HeadDotColor b.HeadDot.Filled=true b.HeadDot.Visible=true
            else b.HeadDot.Visible=false end
        else b.HeadDot.Visible=false end

        if ESP.Settings.LookDir then
            local origin=h.Position local dir=h.CFrame.LookVector*50 local endPos=origin+dir
            local sp1,_,on1=ESP:WorldToScreen(origin) local sp2,_,on2=ESP:WorldToScreen(endPos)
            if on1 and on2 then b.LookDir.From,b.LookDir.To=sp1,sp2 b.LookDir.Color,b.LookDir.Thickness,b.LookDir.Visible=color,1,true else b.LookDir.Visible=false end
        else b.LookDir.Visible=false end

        if ESP.Settings.Velocity then
            local vel=r.Velocity
            if vel.Magnitude>0.1 then
                local origin=rp local endPos=rp+vel.Unit*30
                local sp1,_,on1=ESP:WorldToScreen(origin) local sp2,_,on2=ESP:WorldToScreen(endPos)
                if on1 and on2 then b.Velocity.From,b.Velocity.To=sp1,sp2 b.Velocity.Color,b.Velocity.Thickness,b.Velocity.Visible=Color3.fromRGB(255,255,0),1,true else b.Velocity.Visible=false end
            else b.Velocity.Visible=false end
        else b.Velocity.Visible=false end

        proc[p]=true
    end

    for p in pairs(ESP.Boxes) do if not proc[p] then ESP:HidePlayerDrawings(p) end end
end

function ESP:Start()
    ESP:CleanAll()
    ESP.Conn=RunService.RenderStepped:Connect(ESP.Update)
end

function ESP:Stop()
    if ESP.Conn then ESP.Conn:Disconnect() ESP.Conn=nil end
    ESP:CleanAll()
end

Players.PlayerRemoving:Connect(function(p) ESP:CleanPlayer(p) end)

function ESP:Init(tab, library, flags)
    local self=setmetatable({},ESP)
    self.Tab=tab
    self.Library=library
    self.Flags=flags

    local Sec=tab:Section({Title="ESP",Icon="eye",Opened=true})
    Sec:Toggle({Title="Enable",Value=false,Callback=function(v)ESP.Settings.Enabled=v if v then ESP:Start()else ESP:Stop()end end})
    Sec:Slider({Title="Max Distance",Step=100,Value={Min=100,Max=10000,Default=3000},Callback=function(v)ESP.Settings.MaxDist=v end})
    Sec:Toggle({Title="Team Check",Value=false,Callback=function(v)ESP.Settings.TeamCheck=v end})
    Sec:Toggle({Title="Team Color",Value=false,Callback=function(v)ESP.Settings.TeamColor=v end})
    Sec:Toggle({Title="Rainbow",Value=false,Callback=function(v)ESP.Settings.Rainbow=v end})
    Sec:Toggle({Title="Vis Check",Value=false,Callback=function(v)ESP.Settings.VisCheck=v end})
    Sec:Toggle({Title="Wall Check",Value=true,Callback=function(v)ESP.Settings.WallCheck=v end})

    local SecBox=tab:Section({Title="Box",Icon="square",Opened=true})
    SecBox:Dropdown({Title="Style",Values={"Corner","Full","Circle","Diamond","Crosshair"},Value="Corner",Callback=function(v)ESP.Settings.BoxStyle=v end})
    SecBox:Colorpicker({Title="Color",Default=ESP.Settings.BoxColor,Transparency=0,Callback=function(v)ESP.Settings.BoxColor=v end})
    SecBox:Slider({Title="Thickness",Step=0.5,Value={Min=1,Max=6,Default=2},Callback=function(v)ESP.Settings.BoxThickness=v end})
    SecBox:Toggle({Title="Fill Box",Value=false,Callback=function(v)ESP.Settings.BoxFill=v end})
    SecBox:Toggle({Title="Glow",Value=false,Callback=function(v)ESP.Settings.BoxGlow=v end})
    SecBox:Slider({Title="Corner Length",Step=1,Value={Min=6,Max=40,Default=22},Callback=function(v)ESP.Settings.CornerLen=v end})

    local SecChams=tab:Section({Title="Chams",Icon="shirt",Opened=true})
    SecChams:Toggle({Title="Enable",Value=false,Callback=function(v)ESP.Settings.Chams=v end})
    SecChams:Colorpicker({Title="Fill Color",Default=ESP.Settings.ChamsFillColor,
