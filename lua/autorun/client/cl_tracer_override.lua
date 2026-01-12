SeamlessPortals = SeamlessPortals or {}

if CLIENT then timer.Simple(0, function()
  local all = effects.GetList() or {}
  local eff = all["ToolTracer"]

  -- General effect rendering function
  local function DoEffectRender(self)
    if ( self.Alpha < 1 ) then return end

    render.SetMaterial( self.Mat )
    local texcoord = math.Rand( 0, 1 )

    local norm = ( self.StartPos - self.EndPos ) * self.Life

    self.Length = norm:Length()

    for i = 1, 3 do

      render.DrawBeam( self.StartPos - norm,
            self.EndPos,
            8,
            texcoord,
            texcoord + self.Length / 128,
            color_white )
    end

    render.DrawBeam( self.StartPos,
            self.EndPos,
            8,
            texcoord,
            texcoord + ( ( self.StartPos - self.EndPos ):Length() / 128 ),
            Color( 255, 255, 255, 128 * ( 1 - self.Life ) ) )
  end

  if eff then
    -- Keep the old Render if you want to call it
    SeamlessPortals.ToolTraceEffRender = eff.Render

    -- Override the tool trace render with the new routine
    eff.Render = DoEffectRender

    -- Optionally call SeamlessPortals.ToolTraceEffRender(self) here if needed

    -- Print the initialized effect status
    print("Tool trace override [eff]:", DoEffectRender)
  else
    -- Fallback: register a full effect if ToolTracer does not exist yet
    local EFFECT = {}
          EFFECT.Mat = Material( "effects/tool_tracer" )

    -- Copy or Implement GetTracerShootPos/Init/Think here
    -- See base effect in gamemodes/base/entities/effects/tooltracer.lua
    function EFFECT:Init(data)
      self.Position   = data:GetStart()
      self.WeaponEnt  = data:GetEntity()
      self.Attachment = data:GetAttachment()
      self.StartPos   = self:GetTracerShootPos(self.Position, self.WeaponEnt, self.Attachment)
      self.EndPos     = data:GetOrigin()
      self.Alpha      = 255
      self.Life       = 0
      self:SetRenderBoundsWS(self.StartPos, self.EndPos)
    end

    function EFFECT:Think()
      self.Life = self.Life + FrameTime() * 4
      self.Alpha = 255 * (1 - self.Life)
      return self.Life < 1
    end

    -- Override the tool trace render with the new routine
    EFFECT.Render = DoEffectRender

    effects.Register(EFFECT, "ToolTracer")

    -- Print the initialized effect status
    print("Tool trace override [new]:", DoEffectRender)
  end


end) end
