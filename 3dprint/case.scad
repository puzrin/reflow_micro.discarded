// - Глубину болтов уточнить
include <utils.scad>;

//======================================================================
// Update if other inserts used
// For example, D3.2*3mm
insert_d = 3.6;
insert_h = 4;

magnet_d = 5;
magnet_h = 3;
magnet_x_ofs = 2;
//======================================================================


e = 0.01;
2e = 0.02;

$fn = $preview ? 12 : 48;

wall = 2;
hinges_wall = 4;
right_wall = 2.5;

hinges_r = 3.3;
hinges_section_w = 8;
hinges_margin = 6;
hinges_margin_tail = 6;
hinges_id = 2;
hinges_gap = 0.3;
hinges_len = hinges_section_w*2 + hinges_margin + hinges_margin_tail;

pcb_wx = 145;
pcb_wy = 80;
pcb_margin = 0.25;
pcb_top_margin = 0.2; // extra space for better close of top cap
pcb_h  = 1.6 + pcb_top_margin;

tray_wx = pcb_wx + hinges_wall + right_wall;
tray_wy = pcb_wy + 2*wall;
tray_h  = 16;

tray_inner_h  = tray_h - wall - pcb_h;

cap1_wx = 87;
cap2_wx = tray_wx - cap1_wx;

cap_inner_h = 20;
cap_h = cap_inner_h + wall;

cap_display_mounts_x_shift = -0.0;
cap_display_wx = 52;
cap_display_wy = pcb_wy;
cap_display_inner_h = 4.2;
cap_display_top_wall = 1;
cap_display_h = cap_display_inner_h + cap_display_top_wall;
cap_display_wall = 3;
cap_display_x_inserts_space = 140 - 95;

cap_display_view_wx = 39;
cap_display_view_wy = 51;

case_r_vert = 3;
case_r_bottom = 2;
case_r_top = 2;

btn_base_h = 3;
btn_d = 6.5;
btn_guide_d = btn_d + 0.5 + 6;
pcb_btn_h = 2.7; // Height of button's top point on PCB

module pcb_top(ofs = 0) { tr_y(ofs + pcb_wy/2) children(); }
module pcb_bottom(ofs = 0) { tr_y(ofs - pcb_wy/2) children(); }
module pcb_left(ofs = 0) { tr_x(ofs - tray_wx/2 + hinges_wall) children(); }
module pcb_right(ofs = 0) { tr_x(ofs - tray_wx/2 + hinges_wall + pcb_wx) children(); }

module case_left(ofs = 0) { tr_x(ofs - tray_wx/2) children(); }
module case_right(ofs = 0) { tr_x(ofs + tray_wx/2) children(); }
module case_top(ofs = 0) { tr_y(ofs + tray_wy/2) children(); }
module case_bottom(ofs = 0) { tr_y(ofs - tray_wy/2) children(); }


module m2_screw_hole() {
    translate([0, 0, -e]) {
        cylinder(10, d = 2);
        translate([0, 0, 0.1-e]) cylinder(h = 2, d1 = 4, d2 = 0);
        // Make head outer part long for deep holes
        translate([0, 0, 0.1]) mirror([0, 0, 1]) cylinder(30, d = 4);
    }

}

// Relaxed hole for M2 flat - D 5mm + 2.5mm
module m2_screw_hole_wide() {
    translate([0, 0, -e]) {
        cylinder(10, d = 2.5);
        // Create bigger cone, for extra head dia
        translate([0, 0, 0.1-e-0.236]) cylinder(h = 2.236, d1 = 5, d2 = 0);
        // Make head outer part long for deep holes
        translate([0, 0, 0.1-0.236]) mirror([0, 0, 1]) cylinder(30, d = 5);
    }

}


module fan50_latch(width = 10) {
    translate([width/2, 0.2, -e])
    rotate([0, -90, 0])
    linear_extrude(width)
    polygon([
        [0, 0],
        [11.3, 0],
        [12.8, -1.5],
        [14, -1.5],
        [14, 2],
        [0, 2]
    ]);
}

module fan50_guides() {
    translate([0, -1, 0]) {
        translate([-13, 25, wall]) fan50_latch();
        mirror([1, 0, 0]) translate([-13, 25, wall]) fan50_latch();
        mirror([0, 1, 0]) translate([-13, 25, wall]) fan50_latch();
        rotate([0, 0, 180]) translate([-13, 25, wall]) fan50_latch();

        translate([25, -10, wall - e])
        cube([1.5, 20, 1]);

        mirror([1, 0, 0])
        translate([25, -10, wall - e])
        cube([1.5, 20, 1]);
    }
}

module fan50_hole() {
    rotate([0, 0, -90])
    skew([ 0, 50, 0, 0, 0, 0])
    translate([0, 0, -e])
    rcube([46, 46, wall + 2e], r = 2);
}

module fan50_grill() {
    rotate([0, 0, -90])
    skew([ 0, 50, 0, 0, 0, 0])
    for(i = [-21:4.0:20]) {
        translate([i, -25, 0]) cube([2, 50, 2]);
    }

    translate([-1, -27, 0]) cube([2, 54, 2]);
}

module hinges_add() {
    rotate([-90, 0, 0])
    translate([0, 0, hinges_margin])
    hull() {
        cylinder(hinges_section_w*2, r = hinges_r);
        cube([hinges_r, hinges_r*sqrt(2), hinges_section_w*2]);
    }
}

module hinges_substract(second = false) {
    rotate([-90, 0, 0]) {
        // through hole
        cylinder(hinges_len, d = hinges_id);
        // screw head space
        translate([0, 0, -e])
        cylinder(hinges_margin+2e, d = 5.5);
        // screw nut space
        translate([0, 0, hinges_len - hinges_margin_tail - e])
        cylinder(hinges_margin_tail, d = 5.5);
        // hinge space
        translate([0, 0, second == false ? hinges_margin + hinges_section_w -0.1 : hinges_margin - hinges_gap])
        cylinder(hinges_section_w + hinges_gap + 0.1, r = hinges_r + hinges_gap);
    }
}

module tray_pcb_support(h = tray_h-pcb_h) {
    difference() {
        rcube([7, 7, h], r=1);

        translate([0, 0, h + e])
        mirror([0, 0, 1]) {
            cylinder(insert_h, d = insert_d);
            cylinder(insert_h+5, d = 2.5);
        }
    }
}

module wire_latch() {
    h = cap_h-2;

    rotate([0, 90, 0])
    linear_extrude(6)
    polygon([
        [0, 0],
        [-h, 0],
        [-h, 2],
        [-h+1, 2.5],
        [-h+2, 2],
        [0, 2]
    ]);
}

module magnet_holder(h = 10, wx = 7, wy = 7, md = 5, mh = 3) {
    difference() {
        rcube([wx, wy, h - mh + 1]);
        tr_z(h - mh - 0.2) cylinder(h = mh+10, d = md+0.5);
    }
}

module _tray_base() {
    difference() {
        rcube(
            [tray_wx, tray_wy, tray_h],
            r = case_r_vert,
            rbottom = case_r_bottom
        );

        //translate([-(tray_wx-tray_inner_wx)/2 + hinges_wall + 1, 0, wall])
        pcb_left(1) pcb_bottom(1) tr_z(wall)
        rcube([pcb_wx-2, pcb_wy-2, tray_h], r=2, rbottom=case_r_bottom, center=false);

        pcb_bottom(-pcb_margin) pcb_left(-pcb_margin) tr_z(tray_h-pcb_h)
        rcube(
            [pcb_wx+pcb_margin*2, pcb_wy+pcb_margin*2, pcb_h+e],
            center=false,
            r=0.01
        );
    }
}


module tray() {
    difference() {
        union() {
            _tray_base();

            // PCB + Display supports (solid, no holes)
            pcb_right(-5) pcb_bottom(3) tr_z(wall)
            rcube([8, 8, tray_h-pcb_h - wall + e]);

            mirror_y()
            pcb_right(-5) pcb_bottom(3) tr_z(wall)
            rcube([8, 8, tray_h-pcb_h - wall + e]);

            pcb_right(-50) pcb_bottom(3) tr_z(wall)
            rcube([8, 8, tray_h-pcb_h - wall + e]);

            mirror_y()
            pcb_right(-50) pcb_bottom(3) tr_z(wall)
            rcube([8, 8, tray_h-pcb_h - wall + e]);

            // Boot0 button guide
            // Height = inner - btn_height - btn_base_h - safety_space
            pcb_right(-7) pcb_top(-32)
            cylinder((tray_h - pcb_h) - pcb_btn_h - btn_base_h - 0.2, d=btn_guide_d);

            // Hinges addons
            case_left() case_bottom() tr_z(tray_h)
            hinges_add();

            mirror_y()
            case_left() case_bottom() tr_z(tray_h)
            hinges_add();

            // Hinge angle limiter
            case_left() tr_z(tray_h - hinges_r)
            rotate([90, 45, 0])
            cube([hinges_r*sqrt(2), hinges_r*sqrt(2), tray_wy - 2*hinges_len], center=true);
        }

        // Fan wire slot
        pcb_left() pcb_bottom() tr_z(tray_h-pcb_h-5+e)
        cube([4, 2.6, 10]);

        // Boot0 button guide hole
        pcb_right(-7) pcb_top(-32) tr_z(-e)
        cylinder(tray_h, d=btn_d+0.5);

        // Holes in supports for 8mm M2 screws (with 3.3mm display cap inserts)
        pcb_right(-5) pcb_bottom(3) tr_z(tray_h - (8-3.3))
        m2_screw_hole_wide();

        mirror_y()
        pcb_right(-5) pcb_bottom(3) tr_z(tray_h - (8-3.3))
        m2_screw_hole_wide();

        pcb_right(-50) pcb_bottom(3) tr_z(tray_h - (8-3.3))
        m2_screw_hole_wide();

        mirror_y()
        pcb_right(-50) pcb_bottom(3) tr_z(tray_h - (8-3.3))
        m2_screw_hole_wide();

        // USB connector
        pcb_right(-27.1) pcb_top(-5) tr_z(tray_h - pcb_h - 2.8/2 - 0.2)
        rotate([-90, 0, 0])
        translate([0, -5, 0])
        rcube([8.6, 2.8 + 10, 10], r=1.3);

        // Hinges groves
        case_left() case_bottom() tr_z(tray_h)
        hinges_substract(second = true);

        mirror_y()
        case_left() case_bottom() tr_z(tray_h)
        hinges_substract(second = true);
    }

    // PCB supports
    pcb_left(10) pcb_bottom(3) tr_z(wall-e)
    tray_pcb_support(tray_h - pcb_h - wall);

    mirror_y()
    pcb_left(10) pcb_bottom(3) tr_z(wall-e)
    tray_pcb_support(tray_h - pcb_h - wall);

    // Magnet holders
    case_right(-cap2_wx + magnet_d/2 + magnet_x_ofs)
    pcb_top(-wall*0.5 - magnet_d/2)
    tr_z(e)
    magnet_holder(h = tray_h - pcb_h, wx=8+e, wy=7);

    mirror_y()
    case_right(-cap2_wx + magnet_d/2 + magnet_x_ofs)
    pcb_top(-wall*0.5 - magnet_d/2)
    tr_z(e)
    magnet_holder(h = tray_h - pcb_h, wx=8+e, wy=7);


}


module cap1() {
    diag = 14;

    difference() {
        union() {
            difference() {
                // enlarge & cut side where rounding not required
                tr_x(cap1_wx/2+10/2)
                rcube(
                    [cap1_wx+10, tray_wy, cap_h],
                    r = case_r_vert,
                    rbottom = case_r_top
                );
                tr_x(100/2 + cap1_wx)
                cube([100, tray_wy*2, cap_h*3], center = true);
            }

            // Hinges addons
            case_bottom() tr_z(cap_h) hinges_add();

            mirror_y()
            case_bottom() tr_z(cap_h) hinges_add();
        }

        // Fan wire slot
        pcb_top() translate([hinges_wall, 0,  cap_h-5+e])
        mirror([0, 1, 0]) cube([3, 2.6, 5]);

        // Remove inner
        translate([hinges_wall + 0.5, -tray_wy/2 + wall, wall])
        rcube(
            [cap1_wx+10, tray_wy - 2*wall, cap_h - wall + e],
            center = false,
            r = case_r_vert,
            rbottom = 1 //case_r_top
        );

        // Remove rounding for Cap2 hinges
        translate([cap1_wx-cap_inner_h+e, -tray_wy/2 + wall, wall])
        cube(cap_inner_h);
        mirror([0, 1, 0])
        translate([cap1_wx-cap_inner_h+e, -tray_wy/2 + wall, wall])
        cube(cap_inner_h);

        // Cap2 hinges rounding & hole
        translate([cap1_wx, tray_wy/2+e, cap_h])
        rotate([90, 180, 0])
        qfillet(tray_wy+2e, cap_inner_h/2);

        translate([cap1_wx - cap_inner_h/2, tray_wy/2, cap_h - cap_inner_h/2])
        rotate([90, 0, 0])
        m2_screw_hole();

        translate([cap1_wx - cap_inner_h/2, -tray_wy/2, cap_h - cap_inner_h/2])
        rotate([-90, 0, 0])
        m2_screw_hole();

        // Hinges groves
        case_bottom() tr_z(cap_h)
        hinges_substract(second = false);

        mirror_y()
        case_bottom() tr_z(cap_h)
        hinges_substract(second = false);
    }

    // Fan wire latches
    translate([25, tray_wy/2 - wall - 3, 0]) wire_latch();
    translate([50, tray_wy/2 - wall - 3, 0]) wire_latch();
}


module cap2() {
    fan_offset = 8;

    difference() {
        union() {
            difference() {
                translate([cap2_wx/2+10/2, 0, 0])
                rcube(
                    [cap2_wx+10, tray_wy, cap_h],
                    r = case_r_vert,
                    rbottom = case_r_top
                );
                translate([100/2 + cap2_wx, 0, 0])
                cube([100, tray_wy*2, cap_h*3], center = true);

                // Inner
                translate([wall, -tray_wy/2 + wall, wall])
                rcube(
                    [cap2_wx + 2*wall, tray_wy - 2*wall, cap_h],
                    center=false,
                    r = 2,
                    rbottom = 1 //case_r_top
                );

                // Fanair hole
                translate([fan_offset+25, 0, 0]) fan50_hole();
            }

            // Fans latches
            translate([fan_offset+25, 0, 0]) fan50_guides();
        }

        // Small gap for hinges
        translate([cap2_wx-0.2, -tray_wy/2-e, wall])
        cube([wall, tray_wy+2e, cap_h]);
    }

    translate([fan_offset+25, 0, 0]) fan50_grill();


    // Hinges
    translate([cap2_wx, -tray_wy/2 + wall - e, 0])
    difference() {
        translate([-wall-0.3, 0, 0])
        cube([cap_inner_h + wall, wall, cap_h]);

        translate([cap_inner_h-0.3, wall+e, wall+0.3])
        rotate([90, -90, 0])
        qfillet(wall + 2e, cap_inner_h/2);

        translate([-e, -e, -e])
        cube([cap_inner_h+e, wall*3, wall+0.3+2e]);

        translate([cap_inner_h/2, -e, cap_inner_h/2 + wall])
        rotate([-90, 0, 0])
        cylinder(tray_wy + 2e, d = 2);
    }

    translate([cap2_wx, tray_wy/2 - 2*wall + e, 0])
    difference() {
        translate([-wall-0.3, 0, 0])
        cube([cap_inner_h + wall, wall, cap_h]);

        translate([cap_inner_h-0.3, wall+e, wall+0.3])
        rotate([90, -90, 0])
        qfillet(wall + 2e, cap_inner_h/2);

        translate([-e, -e, -e])
        cube([cap_inner_h+e, wall*3, wall+0.3+2e]);

        translate([cap_inner_h/2, -e, cap_inner_h/2 + wall])
        rotate([-90, 0, 0])
        cylinder(tray_wy + 2e, d = 2);
    }

    // Magnet holders
    pcb_top(-magnet_d/2 - wall*0.5)
    tr_x(cap2_wx - magnet_d/2 - magnet_x_ofs)
    tr_z(wall-e)
    magnet_holder(h=cap_h-wall, wx=7.5, wy=8.5);

    mirror([0, 1, 0])
    pcb_top(-magnet_d/2 - wall*0.5)
    tr_x(cap2_wx - magnet_d/2 - magnet_x_ofs)
    tr_z(wall-e)
    magnet_holder(h=cap_h-wall, wx=7.5, wy=8.5);

    pcb_top(-5) tr_x(right_wall+(50+5)/2) tr_z(wall-e)
    magnet_holder(h = cap_h - cap_display_h - 0.4 - wall, wx=7.5, wy=7.5);

    // Enforce edge
    translate([cap2_wx-6/2, 0, wall-e])
    skew([0, 50, 0, 0, 0, 0])
    tr_z(1/2)
    cube([6, tray_wy-4*wall+e, 1], center = true);

}

module _cap_display_insert_hole() {
    translate([0, 0, cap_display_h + e])
    mirror([0, 0, 1])
    cylinder(insert_h, d = insert_d);
}

module cap_display() {
    difference() {
        rcube(
            [cap_display_wx, cap_display_wy, cap_display_h],
            r=2.5,
            rbottom=1.5
        );

        // Inner
        translate([0, 0, cap_display_top_wall])
        rcube([cap_display_wx - cap_display_wall*2, cap_display_wy - cap_display_wall*4, cap_display_inner_h+e], r=0.1);
 
        // Flat cable space
        translate([0, 0, cap_display_top_wall])
        rcube([cap_display_wx - cap_display_wall*2 - 8, cap_display_wy - cap_display_wall*4 + 4, cap_display_inner_h+e], r=0.1);

        // Visible area hole
        inc = cap_display_top_wall * tan(50) * 2;
        hull() {
            tr_z(cap_display_top_wall)
            cube(
                [cap_display_view_wx, cap_display_view_wy, e],
                center=true
            );
            cube(
                [cap_display_view_wx + inc, cap_display_view_wy + inc, e],
                center=true
            );
        }

        x_fix = cap_display_mounts_x_shift;

        // Inserts
        translate([-cap_display_x_inserts_space/2 + x_fix, -pcb_wy/2 + 3, 0])
        _cap_display_insert_hole();

        translate([-cap_display_x_inserts_space/2 + x_fix, pcb_wy/2 - 3, 0])
        _cap_display_insert_hole();

        translate([cap_display_x_inserts_space/2 + x_fix, -pcb_wy/2 + 3, 0])
        _cap_display_insert_hole();

        translate([cap_display_x_inserts_space/2 + x_fix, pcb_wy/2 - 3, 0])
        _cap_display_insert_hole();

        // Magnet hole
        //translate([0, cap_display_wy/2 - 8.5/2, cap_display_top_wall])
        pcb_top(-5) tr_z(cap_display_top_wall)
        cylinder(h=cap_display_h, d=magnet_d+0.5);
    }

    // Magnet
    //translate([0, cap_display_wy/2 - 8.5/2, 0])
    pcb_top(-5)
    difference () {
        tr_z(cap_display_top_wall-e)
        cylinder(h=cap_display_top_wall+0.5, d=magnet_d+2.5);

        tr_z(cap_display_top_wall-e)
        cylinder(h=cap_display_h, d=magnet_d+0.5);
    }
}

module btn_cap() {
    // Height = (inner_h + wall) - btn_h - space - cap_deepness
    cylinder((tray_h - pcb_h) - pcb_btn_h - 0.2, d=btn_d);
    cylinder(btn_base_h, d=btn_d+2);
}

module all(3d = false) {
    translate([tray_wx/2, 0, 0])
    tray();

    if (3d == true) {
        translate([-40, 0, 8])
        rotate([180, -135, 0])
        cap1();

        translate([-50, 0, 160])
        rotate([0, 135, 0])
        cap2();
    } else {
        translate([0, -100, 0])
        cap1();

        translate([0, -200, 0])
        cap2();
    }

    translate([120, 100, 0])
    cap_display();

    translate([165, -17, 0])
    btn_cap();
}

//mode = 3;

if (!is_undef(mode) && mode == 0) { tray(); }
else if (!is_undef(mode) && mode == 1) { cap1(); }
else if (!is_undef(mode) && mode == 2) { cap2(); }
else if (!is_undef(mode) && mode == 3) { cap_display(); }
else if (!is_undef(mode) && mode == 4) { btn_cap(); }
else { all(); }
