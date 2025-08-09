# ===== Escudos de radiación elásticos =====
shield_rad_len   = p_bus_w * 1.4   # largo total del cilindro de escudo
shield_rad_r     = max(p_bus_d, p_bus_h) / 1.5  # radio medio
shield_gap_side  = 40.0            # separación radial desde la piel del bus
shield_cc_t      = 3.0             # espesor C/C exterior
shield_kevl_t    = 6.0             # espesor Kevlar+epoxy
shield_flex_t    = 2.5             # espesor capa flexible
shield_seg_count = 24              # segmentos elásticos (más bajo = más separados)

def build_radiation_shields(doc):
    objs = []
    # Centro alineado con el bus
    base_x = 0.0
    base_y = 0.0
    base_z = 0.0
    R_ext  = (max(p_bus_d, p_bus_h) / 2.0) + shield_gap_side

    # Capa exterior C/C
    cyl_cc = Part.makeCylinder(R_ext, shield_rad_len, App.Vector(-shield_rad_len/2.0,0,0), App.Vector(1,0,0))
    inner_cc = Part.makeCylinder(R_ext - shield_cc_t, shield_rad_len, App.Vector(-shield_rad_len/2.0,0,0), App.Vector(1,0,0))
    shell_cc = cyl_cc.cut(inner_cc)
    objs.append(add_part(doc, shell_cc, "RadShield_CC", color=(0.15,0.15,0.15), transparency=0))

    # Capa intermedia Kevlar
    R_kevl = R_ext - shield_cc_t
    cyl_kevl = Part.makeCylinder(R_kevl, shield_rad_len, App.Vector(-shield_rad_len/2.0,0,0), App.Vector(1,0,0))
    inner_kevl = Part.makeCylinder(R_kevl - shield_kevl_t, shield_rad_len, App.Vector(-shield_rad_len/2.0,0,0), App.Vector(1,0,0))
    shell_kevl = cyl_kevl.cut(inner_kevl)
    objs.append(add_part(doc, shell_kevl, "RadShield_Kevlar", color=(0.85,0.65,0.13), transparency=0.3))

    # Capa flexible interior
    R_flex = R_kevl - shield_kevl_t
    cyl_flex = Part.makeCylinder(R_flex, shield_rad_len, App.Vector(-shield_rad_len/2.0,0,0), App.Vector(1,0,0))
    inner_flex = Part.makeCylinder(R_flex - shield_flex_t, shield_rad_len, App.Vector(-shield_rad_len/2.0,0,0), App.Vector(1,0,0))
    shell_flex = cyl_flex.cut(inner_flex)
    objs.append(add_part(doc, shell_flex, "RadShield_Flex", color=(0.75,0.75,0.8), transparency=0.6))

    # Segmentación elástica: aros finos alrededor (como juntas)
    seg_spacing = shield_rad_len / shield_seg_count
    for i in range(shield_seg_count+1):
        pos_x = -shield_rad_len/2.0 + i*seg_spacing
        tor = Part.makeTorus(R_flex - shield_flex_t/2.0, 1.0, App.Vector(pos_x,0,0), App.Vector(1,0,0))
        objs.append(add_part(doc, tor, f"RadShield_Seg_{i}", color=(0.6,0.6,0.65), transparency=0.2))
    return objs
