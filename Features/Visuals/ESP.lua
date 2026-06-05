--[[
    ╔══════════════════════════════════════════════════════════════╗
    ║           HYPER UI - ESP SYSTEM - CORNER PRO                 ║
    ║         Zero Ghosting | Full Customization                    ║
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
    Enabled = false, MaxDist = 3000, TeamCheck = false, TeamColor = false, Rainbow = false, VisCheck = false,
    CornerColor = Color3.fromRGB(255, 255, 255), CornerThick = 2, CornerLen = 22,
    Name = true, NameColor = Color3.fromRGB(255, 255, 255), NameSize = 13, NameOutline = true,
    Dist = true, DistColor = Color3.fromRGB(180, 180, 180), DistSize = 12, DistBrackets = true,
    HP = true, HPPos = "Left", HPThick = 3, HPBG = Color3.fromRGB(20, 20, 20),
    HDot = true, HDotColor = Color3.fromRGB(255, 255, 255), HDotSize = 7, HDotGlow = true, HDotGlowAlpha = 0.7,
    Tracer = false, TracerColor = Color3.fromRGB(255, 255, 255), TracerOrigin = "Bottom", TracerThick = 1,
    Snap = false, SnapColor = Color3.fromRGB(255, 255, 255), SnapThick = 1,
    Weapon = false, WeaponColor = Color3.fromRGB(255, 200, 50),
    Skeleton = false, SkeletonColor = Color3.fromRGB(255, 255, 255), SkeletonThick = 1,
    InfoPanel = false, InfoColor = Color3.fromRGB(255, 255, 255),
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
    return ESP.Settings.CornerColor
end

function ESP:CreatePlayer(p)
    local b={}
    for i=1,30 do b[i]=Drawing.new("Line") b[i].Visible=false end
    b.Name=Drawing.new("Text") b.Name.Center=true b.Name.Visible=false
    b.Dist=Drawing.new("Text") b.Dist.Center=true b.Dist.Visible=false
    b.Weapon=Drawing.new("Text") b.Weapon.Center=true b.Weapon.Visible=false
    b.Info=Drawing.new("Text") b.Info.Center=true b.Info.Visible=false
    b.HPBg=Drawing.new("Square") b.HPBg.Filled=true b.HPBg.Visible=false
    b.HPFill=Drawing.new("Square") b.HPFill.Filled=true b.HPFill.Visible=false
    b.Tracer=Drawing.new("Line") b.Tracer.Visible=false
    b.Snap=Drawing.new("Line") b.Snap.Visible=false
    b.HDot=Drawing.new("Circle") b.HDot.Filled=true b.HDot.Visible=false
    b.HDotGlow=Drawing.new("Circle") b.HDotGlow.Filled=true b.HDotGlow.Visible=false
    b._style="Corner"
    ESP.Boxes[p]=b
end

function ESP:CleanPlayer(p)
    if ESP.Boxes[p] then for _,v in pairs(ESP.Boxes[p]) do if type(v)=="table" and v.Remove then v.Visible=false v:Remove() end end ESP.Boxes[p]=nil end
end

function ESP:CleanAll()
    for p in pairs(ESP.Boxes) do ESP:CleanPlayer(p) end
    ESP.Boxes={}
end

function ESP:Update()
    local mt=LocalPlayer.Team
    local cp=Camera.CFrame.Position
    local vp=Camera.ViewportSize
    local cx,cy=vp.X/2,vp.Y
    local proc={}

    for _,p in ipairs(Players:GetPlayers()) do
        if p==LocalPlayer then continue end
        if ESP.Settings.TeamCheck and p.Team==mt then ESP:CleanPlayer(p) continue end

        local c=p.Character
        if not c then ESP:CleanPlayer(p) continue end

        local h=ESP:FindHead(c)
        local r=ESP:FindRoot(c)
        local hum=c:FindFirstChildOfClass("Humanoid")
        if not h or not r then ESP:CleanPlayer(p) continue end

        local rp=r.Position
        local dist=(cp-rp).Magnitude
        if dist>ESP.Settings.MaxDist then ESP:CleanPlayer(p) continue end

        if ESP.Settings.VisCheck then
            local ray=Ray.new(cp,(rp-cp).Unit*dist)
            local hit=workspace:FindPartOnRay(ray,LocalPlayer.Character)
            if hit and hit.Parent~=c then ESP:CleanPlayer(p) continue end
        end

        local rsp=Camera:WorldToViewportPoint(rp)
        if rsp.Z<=0 then ESP:CleanPlayer(p) continue end

        local hsp=Camera:WorldToViewportPoint(h.Position+Vector3.new(0,0.5,0))
        local lsp=Camera:WorldToViewportPoint(rp-Vector3.new(0,3.5,0))

        local bh=math.abs(hsp.Y-lsp.Y)
        local bw=bh*0.5
        local x=rsp.X-bw/2
        local y=hsp.Y

        if not ESP.Boxes[p] then ESP:CreatePlayer(p) end
        local b=ESP.Boxes[p]

        for i=1,30 do if b[i] and b[i].Remove then b[i].Visible=false end end

        local color=ESP:GetColor(p)
        local cl=math.clamp(bw*0.25,8,ESP.Settings.CornerLen)
        local ct=ESP.Settings.CornerThick

        b[1].From,b[1].To=Vector2.new(x,y),Vector2.new(x+cl,y) b[1].Color,b[1].Thickness,b[1].Visible=color,ct,true
        b[2].From,b[2].To=Vector2.new(x,y),Vector2.new(x,y+cl) b[2].Color,b[2].Thickness,b[2].Visible=color,ct,true
        b[3].From,b[3].To=Vector2.new(x+bw-cl,y),Vector2.new(x+bw,y) b[3].Color,b[3].Thickness,b[3].Visible=color,ct,true
        b[4].From,b[4].To=Vector2.new(x+bw,y),Vector2.new(x+bw,y+cl) b[4].Color,b[4].Thickness,b[4].Visible=color,ct,true
        b[5].From,b[5].To=Vector2.new(x,y+bh),Vector2.new(x+cl,y+bh) b[5].Color,b[5].Thickness,b[5].Visible=color,ct,true
        b[6].From,b[6].To=Vector2.new(x,y+bh-cl),Vector2.new(x,y+bh) b[6].Color,b[6].Thickness,b[6].Visible=color,ct,true
        b[7].From,b[7].To=Vector2.new(x+bw-cl,y+bh),Vector2.new(x+bw,y+bh) b[7].Color,b[7].Thickness,b[7].Visible=color,ct,true
        b[8].From,b[8].To=Vector2.new(x+bw,y+bh-cl),Vector2.new(x+bw,y+bh) b[8].Color,b[8].Thickness,b[8].Visible=color,ct,true

        if ESP.Settings.Name then
            b.Name.Text=p.DisplayName b.Name.Color=ESP.Settings.NameColor b.Name.Size=ESP.Settings.NameSize
            b.Name.Position=Vector2.new(rsp.X,y-16) b.Name.Visible=true b.Name.Outline=ESP.Settings.NameOutline
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

        if ESP.Settings.HDot then
            local hcsp=Camera:WorldToViewportPoint(h.Position)
            b.HDot.Position,b.HDot.Radius=Vector2.new(hcsp.X,hcsp.Y),ESP.Settings.HDotSize
            b.HDot.Color,b.HDot.Visible=ESP.Settings.HDotColor,true
            if ESP.Settings.HDotGlow then
                b.HDotGlow.Position,b.HDotGlow.Radius=Vector2.new(hcsp.X,hcsp.Y),ESP.Settings.HDotSize+4
                b.HDotGlow.Color,b.HDotGlow.Transparency,b.HDotGlow.Visible=ESP.Settings.HDotColor,ESP.Settings.HDotGlowAlpha,true
            end
        else b.HDot.Visible=false b.HDotGlow.Visible=false end

        if ESP.Settings.Tracer then
            local sx=cx
            local sy=ESP.Settings.TracerOrigin=="Bottom"and cy or ESP.Settings.TracerOrigin=="Top"and 0 or cy/2
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
                    if sp1.Z>0 and sp2.Z>0 then
                        b[si].From,b[si].To=Vector2.new(sp1.X,sp1.Y),Vector2.new(sp2.X,sp2.Y)
                        b[si].Color,b[si].Thickness,b[si].Visible=ESP.Settings.SkeletonColor,ESP.Settings.SkeletonThick,true
                        si=si+1
                    end
                end
            end
        end

        if ESP.Settings.InfoPanel then
            local info=p.DisplayName.."\n"
            if hum then info=info.."HP: "..math.floor(hum.Health).."/"..hum.MaxHealth.."\n" end
            info=info.."Dist: "..math.floor(dist).."m"
            b.Info.Text=info b.Info.Color=ESP.Settings.InfoColor b.Info.Size=11
            b.Info.Position=Vector2.new(rsp.X+bw+60,rsp.Y) b.Info.Visible=true
        else b.Info.Visible=false end

        proc[p]=true
    end

    for p in pairs(ESP.Boxes) do if not proc[p] then ESP:CleanPlayer(p) end end
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

    local SecBox=tab:Section({Title="Box",Icon="square",Opened=true})
    SecBox:Colorpicker({Title="Color",Default=ESP.Settings.CornerColor,Transparency=0,Callback=function(v)ESP.Settings.CornerColor=v end})
    SecBox:Slider({Title="Thickness",Step=0.5,Value={Min=1,Max=6,Default=2},Callback=function(v)ESP.Settings.CornerThick=v end})
    SecBox:Slider({Title="Corner Length",Step=1,Value={Min=6,Max=35,Default=22},Callback=function(v)ESP.Settings.CornerLen=v end})

    local SecInfo=tab:Section({Title="Info",Icon="user",Opened=true})
    SecInfo:Toggle({Title="Name",Value=true,Callback=function(v)ESP.Settings.Name=v end})
    SecInfo:Colorpicker({Title="Name Color",Default=ESP.Settings.NameColor,Transparency=0,Callback=function(v)ESP.Settings.NameColor=v end})
    SecInfo:Slider({Title="Name Size",Step=1,Value={Min=10,Max=22,Default=13},Callback=function(v)ESP.Settings.NameSize=v end})
    SecInfo:Toggle({Title="Name Outline",Value=true,Callback=function(v)ESP.Settings.NameOutline=v end})
    SecInfo:Toggle({Title="Distance",Value=true,Callback=function(v)ESP.Settings.Dist=v end})
    SecInfo:Colorpicker({Title="Dist Color",Default=ESP.Settings.DistColor,Transparency=0,Callback=function(v)ESP.Settings.DistColor=v end})
    SecInfo:Slider({Title="Dist Size",Step=1,Value={Min=9,Max=18,Default=12},Callback=function(v)ESP.Settings.DistSize=v end})
    SecInfo:Toggle({Title="Brackets",Value=true,Callback=function(v)ESP.Settings.DistBrackets=v end})

    local SecHP=tab:Section({Title="Health",Icon="heart",Opened=true})
    SecHP:Toggle({Title="HP Bar",Value=true,Callback=function(v)ESP.Settings.HP=v end})
    SecHP:Dropdown({Title="Position",Values={"Left","Right"},Value="Left",Callback=function(v)ESP.Settings.HPPos=v end})
    SecHP:Slider({Title="Thickness",Step=1,Value={Min=2,Max=8,Default=3},Callback=function(v)ESP.Settings.HPThick=v end})
    SecHP:Colorpicker({Title="BG Color",Default=ESP.Settings.HPBG,Transparency=0,Callback=function(v)ESP.Settings.HPBG=v end})

    local SecDot=tab:Section({Title="Head Dot",Icon="circle",Opened=true})
    SecDot:Toggle({Title="Head Dot",Value=true,Callback=function(v)ESP.Settings.HDot=v end})
    SecDot:Colorpicker({Title="Dot Color",Default=ESP.Settings.HDotColor,Transparency=0,Callback=function(v)ESP.Settings.HDotColor=v end})
    SecDot:Slider({Title="Dot Size",Step=1,Value={Min=4,Max=16,Default=7},Callback=function(v)ESP.Settings.HDotSize=v end})
    SecDot:Toggle({Title="Glow",Value=true,Callback=function(v)ESP.Settings.HDotGlow=v end})
    SecDot:Slider({Title="Glow Alpha",Step=0.1,Value={Min=0.3,Max=1,Default=0.7},Callback=function(v)ESP.Settings.HDotGlowAlpha=v end})

    local SecTracer=tab:Section({Title="Tracers",Icon="trending-up",Opened=true})
    SecTracer:Toggle({Title="Tracers",Value=false,Callback=function(v)ESP.Settings.Tracer=v end})
    SecTracer:Colorpicker({Title="Color",Default=ESP.Settings.TracerColor,Transparency=0,Callback=function(v)ESP.Settings.TracerColor=v end})
    SecTracer:Dropdown({Title="Origin",Values={"Bottom","Top","Middle"},Value="Bottom",Callback=function(v)ESP.Settings.TracerOrigin=v end})
    SecTracer:Slider({Title="Thickness",Step=0.5,Value={Min=0.5,Max=4,Default=1},Callback=function(v)ESP.Settings.TracerThick=v end})

    local SecSnap=tab:Section({Title="Snaplines",Icon="minus",Opened=true})
    SecSnap:Toggle({Title="Snaplines",Value=false,Callback=function(v)ESP.Settings.Snap=v end})
    SecSnap:Colorpicker({Title="Color",Default=ESP.Settings.SnapColor,Transparency=0,Callback=function(v)ESP.Settings.SnapColor=v end})
    SecSnap:Slider({Title="Thickness",Step=0.5,Value={Min=0.5,Max=4,Default=1},Callback=function(v)ESP.Settings.SnapThick=v end})

    local SecExtra=tab:Section({Title="Extra",Icon="star",Opened=true})
    SecExtra:Toggle({Title="Weapon",Value=false,Callback=function(v)ESP.Settings.Weapon=v end})
    SecExtra:Colorpicker({Title="Weapon Color",Default=ESP.Settings.WeaponColor,Transparency=0,Callback=function(v)ESP.Settings.WeaponColor=v end})
    SecExtra:Toggle({Title="Skeleton",Value=false,Callback=function(v)ESP.Settings.Skeleton=v end})
    SecExtra:Colorpicker({Title="Skeleton Color",Default=ESP.Settings.SkeletonColor,Transparency=0,Callback=function(v)ESP.Settings.SkeletonColor=v end})
    SecExtra:Slider({Title="Skeleton Thick",Step=0.5,Value={Min=0.5,Max=3,Default=1},Callback=function(v)ESP.Settings.SkeletonThick=v end})
    SecExtra:Toggle({Title="Info Panel",Value=false,Callback=function(v)ESP.Settings.InfoPanel=v end})
    SecExtra:Colorpicker({Title="Info Color",Default=ESP.Settings.InfoColor,Transparency=0,Callback=function(v)ESP.Settings.InfoColor=v end})

    return self
end

return ESP
