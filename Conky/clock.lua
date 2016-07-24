--[[
Clock Rings by londonali1010 (2009)
Configuration by Ninquitassar (2012)

This script draws percentage meters as rings, and also draws clock hands if you want! It is fully customisable; all options are described in the script. This script is based off a combination of my clock.lua script and my rings.lua script.

IMPORTANT: if you are using the 'cpu' function, it will cause a segmentation fault if it tries to draw a ring straight away. The if statement near the end of the script uses a delay to make sure that this doesn't happen. It calculates the length of the delay by the number of updates since Conky started. Generally, a value of 5s is long enough, so if you update Conky every 1s, use update_num > 5 in that if statement (the default). If you only update Conky every 2s, you should change it to update_num > 3; conversely if you update Conky every 0.5s, you should use update_num > 10. ALSO, if you change your Conky, is it best to use "killall conky; conky" to update it, otherwise the update_num will not be reset and you will get an error.

To call this script in Conky, use the following (assuming that you save this script to ~/scripts/rings.lua):
  lua_load ~/scripts/clock_rings-v1.1.1.lua
  lua_draw_hook_pre clock_rings

Changelog:
+ v1.1.1 -- Fixed minor bug that caused the script to crash if conky_parse() returns a nil value (20.10.2009)
+ v1.1 -- Added colour option for clock hands (07.10.2009)
+ v1.0 -- Original release (30.09.2009)
]]
  line_width=2
  line_cap=CAIRO_LINE_CAP_BUTT
  bg_colour=0x000000
  bg_alpha=0.2


--Use these settings to define the origin and extent of your clock.
  clock_r=50

--Coordinates of the centre of the clock, in pixels, from the top left of the Conky window.
  clock_x=60
  clock_y=120

--Colour & alpha of the clock hands
  clock_colour=0xffffff
  clock_alpha=0.6

--Show the seconds hand ?
  show_seconds=true

  cpu_x=400
  cpu_y=435

settings_table = {
  {
    name='time',
    arg='%S',
    max=60,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=clock_x, y=clock_y,
    radius=55,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
  {
    name='time',
    arg='%M.%S',
    max=60,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=clock_x, y=clock_y,
    radius=44,
    thickness=10,
    start_angle=0,
    end_angle=360
  },
  {
    name='time',
    arg='%I.%M',
    max=12,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=clock_x, y=clock_y,
    radius=34,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
  {
    name='battery_percent',
    arg='BAT0',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=375, y=245,
    radius=35,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
  {
    name='cpu',
    arg='cpu0',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=cpu_x, y=cpu_y,
    radius=40,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='cpu',
    arg='cpu1',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=cpu_x, y=cpu_y,
    radius=34,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='cpu',
    arg='cpu2',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=cpu_x, y=cpu_y,
    radius=28,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='cpu',
    arg='cpu3',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=cpu_x, y=cpu_y,
    radius=22,
    thickness=5,
    start_angle=0,
    end_angle=360
  },
  {
    name='memperc',
    arg='/',
    max=100,
    bg_colour=0xffffff,
    bg_alpha=0.1,
    fg_colour=0xd7d7d7,
    fg_alpha=0.6,
    x=400, y=595,
    radius=40,
    thickness=3,
    start_angle=0,
    end_angle=360
  },
}

require 'cairo'

function rgb_to_r_g_b(colour,alpha)
  return ((colour / 0x10000) % 0x100) / 255., ((colour / 0x100) % 0x100) / 255., (colour % 0x100) / 255., alpha
end

function draw_ring(cr,t,pt)
  local w,h=conky_window.width,conky_window.height

  local xc,yc,ring_r,ring_w,sa,ea=pt['x'],pt['y'],pt['radius'],pt['thickness'],pt['start_angle'],pt['end_angle']
  local bgc, bga, fgc, fga=pt['bg_colour'], pt['bg_alpha'], pt['fg_colour'], pt['fg_alpha']

  local angle_0=sa*(2*math.pi/360)-math.pi/2
  local angle_f=ea*(2*math.pi/360)-math.pi/2
  local t_arc=t*(angle_f-angle_0)

  --Draw background ring
  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_f)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(bgc,bga))
  cairo_set_line_width(cr,ring_w)
  cairo_stroke(cr)

  --Draw indicator ring
  cairo_arc(cr,xc,yc,ring_r,angle_0,angle_0+t_arc)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(fgc,fga))
  cairo_stroke(cr)
end

function draw_clock_hands(cr,xc,yc)
  local secs,mins,hours,secs_arc,mins_arc,hours_arc
  local xh,yh,xm,ym,xs,ys

  secs=os.date("%S")
  mins=os.date("%M")
  hours=os.date("%I")

  secs_arc=(2*math.pi/60)*secs
  mins_arc=(2*math.pi/60)*mins+secs_arc/60
  hours_arc=(2*math.pi/12)*hours+mins_arc/12

  --Draw hour hand
  xh=xc+0.65*clock_r*math.sin(hours_arc)
  yh=yc-0.65*clock_r*math.cos(hours_arc)
  cairo_move_to(cr,xc,yc)
  cairo_line_to(cr,xh,yh)
  --
  cairo_set_line_cap(cr,CAIRO_LINE_CAP_ROUND)
  cairo_set_line_width(cr,5)
  cairo_set_source_rgba(cr,rgb_to_r_g_b(clock_colour,clock_alpha))
  cairo_stroke(cr)

  --Draw minute hand
  xm=xc+0.95*clock_r*math.sin(mins_arc)
  ym=yc-0.95*clock_r*math.cos(mins_arc)
  cairo_move_to(cr,xc,yc)
  cairo_line_to(cr,xm,ym)
  --
  cairo_set_line_width(cr,3)
  cairo_stroke(cr)

  cairo_set_line_width (cr, line_width)
  cairo_set_line_cap  (cr, CAIRO_LINE_CAP_BUTT)
  cairo_move_to (cr, 375, 194)
  cairo_line_to (cr, 375, 211)

  cairo_move_to (cr, 60, 43)
  cairo_line_to (cr, 60, 66)

  cairo_move_to (cr, 400, 378)
  cairo_line_to (cr, 400, 393)

  cairo_move_to (cr, 400, 540)
  cairo_line_to (cr, 400, 555)

  cairo_stroke (cr)

  --cairo_set_source_rgba(cr,rgb_to_r_g_b(bg_colour,bg_alpha))
  --cario_fill(cr) 

  -- Draw seconds hand
  if show_seconds then
    xs=xc+1.1*clock_r*math.sin(secs_arc)
    ys=yc-1.1*clock_r*math.cos(secs_arc)
    cairo_move_to(cr,xc,yc)
    cairo_line_to(cr,xs,ys)
    --
    cairo_set_line_width(cr,1)
    cairo_stroke(cr)
  end
end

function conky_clock_rings()
  local function setup_rings(cr,pt)
  local str=''
  local value=0

  str=string.format('${%s %s}',pt['name'],pt['arg'])
  str=conky_parse(str)

  value=tonumber(str)
  if value == nil then value = 0 end

--Les ajouts suivants permettent de corriger le retard prit par les anneaux
  --Ajout wlourf : conversion des minutes en centièmes d'heures
  if pt['arg'] == "%I.%M"  then
    value=os.date("%I")+os.date("%M")/60
    if value>12 then value=value-12 end
  end

  --Ajout Fenouille84 : conversion des secondes en centièmes de minutes
  if pt['arg'] == "%M.%S"  then
    value=os.date("%M")+os.date("%S")/60
  end
  --Fin ajout

  pct=value/pt['max']
  draw_ring(cr,pct,pt)
end

--Check that Conky has been running for at least 5s
if conky_window==nil then return end
  local cs=cairo_xlib_surface_create(conky_window.display,conky_window.drawable,conky_window.visual, conky_window.width,conky_window.height)

  local cr=cairo_create(cs)  

  local updates=conky_parse('${updates}')
  update_num=tonumber(updates)

  if update_num>5 then
    for i in pairs(settings_table) do
      setup_rings(cr,settings_table[i])
    end
  end

  draw_clock_hands(cr,clock_x,clock_y)
end
