// - Глубину болтов уточнить
use <utils.scad>;


e = 0.01;
2e = 0.02;

$fn = $preview ? 12 : 48;

wall = 2;
hinges_wall = 4;
hinges_r = 3.7;
hinges_section_w = 8;
hinges_margin = 6;
hinges_margin_tail = 6;
hinges_id = 2;
hinges_gap = 0.3;
hinges_len = hinges_section_w*2 + hinges_margin + hinges_margin_tail;

pcb_wx = 145;
pcb_wy = 80;
pcb_h  = 1.6;
pcb_x_margin = 0.2;
pcb_y_margin = 0.2;

tray_inner_wx = pcb_wx - wall - 1;
tray_inner_wy = pcb_wy - wall;
tray_inner_h  = 12;

tray_wx = pcb_wx + hinges_wall;
tray_wy = tray_inner_wy + 3*wall;
tray_h  = tray_inner_h + pcb_h + wall;

cap1_wx = 87;
cap2_wx = tray_wx - cap1_wx;

cap_inner_h = 20;
cap_h = cap_inner_h + wall;

cap_display_mounts_x_shift = -0.2;
cap_display_wy_space = 0.2;
cap_display_wx = 51;
cap_display_wy = pcb_wy - cap_display_wy_space*2;
cap_display_inner_h = 4.2;
cap_display_top_wall = 1;
cap_display_h = cap_display_inner_h + cap_display_top_wall;
cap_display_wall = 3;
cap_display_x_inserts_space = 140 - 95;

cap_display_view_wx = 36.75;
cap_display_view_wy = 49;

insert_d = 3.6;
insert_h = 4;

case_r_vert = 3;
case_r_bottom = 1;
case_r_top = 2;


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


module fan50_latch() {
    translate([7/2, 0.2, -e])
    rotate([0, -90, 0])
    linear_extrude(7)
    polygon([
        [0, 0],
        [11.5, 0],
        [12.5, -1],
        [13.5, -1],
        [13.5, 2],
        [0, 2]
    ]);
}

module fan50_guides() {
    translate([-13, 25, wall]) fan50_latch();
    mirror([1, 0, 0]) translate([-13, 25, wall]) fan50_latch();
    mirror([0, 1, 0]) translate([-13, 25, wall]) fan50_latch();
    rotate([0, 0, 180]) translate([-13, 25, wall]) fan50_latch();

    translate([25.2, -10, wall - e]) cube([1.5, 20, 1]);
    mirror([1, 0, 0]) translate([25.2, -10, wall - e]) cube([1.5, 20, 1]);
}


module fan50_hole() {
    rotate([0, 0, -90])
    skew([ 0, 47, 0, 0, 0, 0])
    translate([0, 0, -e])
    rcube([46, 46, wall + 2e], r = 3);
}

module fan50_grill() {
    rotate([0, 0, -90])
    skew([ 0, 47, 0, 0, 0, 0])
    for(i = [-21:4.0:20]) {
        translate([i, -25, 0]) cube([2, 50, 2]);
    }
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
        translate([0, 0, second == false ? hinges_margin + hinges_section_w - hinges_gap/2: hinges_margin - hinges_gap])
        cylinder(hinges_section_w + hinges_gap*1.5, r = hinges_r + hinges_gap);
    }
}

module tray_pcb_support() {
    difference() {
        rcube([7, 7, tray_h-pcb_h], r=1);

        translate([0, 0, tray_h - pcb_h + e])
        mirror([0, 0, 1]) {
            cylinder(insert_h, d = insert_d);
            cylinder(insert_h+5, d = 2.5);
        }

    }
}

module wire_latch() {
    rotate([0, 90, 0])
    linear_extrude(10)
    polygon([
        [0, 0],
        [-16, 0],
        [-16, 2],
        [-15, 3],
        [-14, 2],
        [0, 2]
    ]);
}

module magnet_holder(h = 10, wx = 7, wy = 7, md = 5, mh = 3) {
    difference() {
        rcube([wx, wy, h-0.5]);
        
        translate([0, 0, h - mh - 0.2])
        union() {
            cylinder(h = mh+10, d = md+0.5);
            rotate([0, 0, 90])
            rcube([wx + 10, wx/3, mh+10]);
            rcube([wy + 10, wy/3, mh+10]);
        }
    }
}

module _tray_base() {
    difference() {
        rcube(
            [tray_wx, tray_wy, tray_h],
            r = case_r_vert,
            rbottom = case_r_bottom
        );

        translate([-(tray_wx-tray_inner_wx)/2 + hinges_wall + 1, 0, wall])
        rcube(
            [tray_inner_wx, tray_wy - wall*3, tray_h],
            r = case_r_vert,
            rbottom = case_r_bottom
        );

        translate([tray_wx - wall/2 - pcb_wx, 0, tray_h-pcb_h])
        rcube([
            tray_wx - wall + e + pcb_x_margin*2,
            pcb_wy + 2*pcb_y_margin,
            pcb_h+e
        ], r = 0.01);
    }
}


module tray() {
    difference() {
        union() {
            _tray_base();

            // PCB + Display supports (solid, no holes)
            translate([tray_wx/2 - 5, -pcb_wy/2 + 3, 0])
            rcube([8, 8, tray_h-pcb_h - e]);

            translate([tray_wx/2 - 5, pcb_wy/2 - 3, 0])
            rcube([8, 8, tray_h-pcb_h - e]);

            translate([tray_wx/2 - 50, -pcb_wy/2 + 3, 0])
            rcube([8, 8, tray_h-pcb_h - e]);

            translate([tray_wx/2 - 50, pcb_wy/2 - 3, 0])
            rcube([8, 8, tray_h-pcb_h - e]);

            // Boot0 button guide
            // Height = inner - btn_height - space_0.5_mm - cap_3_mm
            translate([tray_wx/2 - 7, pcb_wy/2 - 32, 0])
            cylinder(tray_h - pcb_h - 2.7 - 0.5 - 3.0, d=12);

            // Hinges addons
            translate([-tray_wx/2, -tray_wy/2, tray_h])
            hinges_add();
            
            mirror([0, 1, 0])
            translate([-tray_wx/2, -tray_wy/2, tray_h])
            hinges_add();

            // Hinge angle limiter
            translate([-tray_wx/2, 0, tray_h - hinges_r])
            rotate([90, 45, 0])
            cube([hinges_r*sqrt(2), hinges_r*sqrt(2), tray_wy - 2*hinges_len], center=true);
        }

        // Fan wire slot
        translate([-tray_wx/2 + hinges_wall, -pcb_wy/2,  tray_h-pcb_h-5+e])
        cube([4, 2.6, 10]);

        // Boot0 button guide hole
        translate([tray_wx/2 - 7, pcb_wy/2 - 32, -e])
        cylinder(tray_h, d=5);

        // Holes in supports for 8mm M2 screws (with 3.3mm display cap inserts)
        translate([tray_wx/2 - 5, -pcb_wy/2 + 3, tray_h - (8-3.3)]) m2_screw_hole_wide();
        translate([tray_wx/2 - 5, pcb_wy/2 - 3, tray_h - (8-3.3)]) m2_screw_hole_wide();
        translate([tray_wx/2 - 50, -pcb_wy/2 + 3, tray_h - (8-3.3)]) m2_screw_hole_wide();
        translate([tray_wx/2 - 50, pcb_wy/2 - 3, tray_h - (8-3.3)]) m2_screw_hole_wide();

        // USB connector
        translate([tray_wx/2 - 27.1, tray_wy/2-5, tray_h - pcb_h - 2.8/2])
        rotate([-90, 0, 0])
        translate([0, -5, 0])
        rcube([8.6, 2.8 + 10, 10], r=1.4);

        // Hinges groves
        translate([-tray_wx/2, -tray_wy/2, tray_h])
        hinges_substract(second = true);

        mirror([0, 1, 0])
        translate([-tray_wx/2, -tray_wy/2, tray_h])
        hinges_substract(second = true);
    }

    // PCB supports
    translate([tray_wx/2 - pcb_wx + 10, -pcb_wy/2 + 3, e])
    tray_pcb_support();

    mirror([0, 1, 0])
    translate([tray_wx/2 - pcb_wx + 10, -pcb_wy/2 + 3, e])
    tray_pcb_support();

    // Magnet holders
    translate([tray_wx/2 - (cap2_wx - 5/2 - wall), tray_wy/2 - wall*1.5 - 5/2, e])
    magnet_holder(h = tray_h - pcb_h, wx=7+e, wy = 7, md = 5);

    mirror([0, 1, 0])
    translate([tray_wx/2 - (cap2_wx - 5/2 - wall), tray_wy/2 - wall*1.5 - 5/2, e])
    magnet_holder(h = tray_h - pcb_h, wx=7+e, wy = 7, md = 5);


}


module cap1() {
    diag = 14;

    difference() {
        union() {
            difference() {
                // enlarge & cut side where rounding not required
                translate([cap1_wx/2+10/2, 0, 0])
                rcube(
                    [cap1_wx+10, tray_wy, cap_h],
                    r = case_r_vert,
                    rbottom = case_r_top
                );
                translate([100/2 + cap1_wx, 0, 0])
                cube([100, tray_wy*2, cap_h*3], center = true);
            }

            // Hinges addons
            translate([0, -tray_wy/2, cap_h])
            hinges_add();

            mirror([0, 1, 0])
            translate([0, -tray_wy/2, cap_h])
            hinges_add();
        }

        // Fan wire slot
        translate([hinges_wall, pcb_wy/2,  cap_h-5+e])
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
        translate([0, -tray_wy/2, cap_h])
        hinges_substract(second = false);

        mirror([0, 1, 0])
        translate([0, -tray_wy/2, cap_h])
        hinges_substract(second = false);
    }

    // Fan wire latches
    translate([15, tray_wy/2 - wall - 3 - 0.3, 0]) wire_latch();
    translate([45, tray_wy/2 - wall - 3 - 0.3, 0]) wire_latch();
}


module cap2() {
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
                    r = case_r_vert,
                    rbottom = 1 //case_r_top
                );

                // Fanair hole
                translate([wall+1+25, 0, 0]) fan50_hole();
            }

            // Fans screws guildes/latches
            translate([wall+1+25, 0, 0]) fan50_guides();
        }

        // Small gap for hinges
        translate([cap2_wx-0.2, -tray_wy/2-e, wall])
        cube([wall, tray_wy+2e, cap_h]);
    }

    translate([3+25, 0, 0]) fan50_grill();


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
    translate([cap2_wx - 5/2 - wall, tray_wy/2 - wall*1.5 - 5/2, wall-e])
    magnet_holder(h = cap_h-wall, wx=7, wy = 9, md = 5);

    mirror([0, 1, 0])
    translate([cap2_wx - 5/2 - wall, tray_wy/2 - wall*1.5 - 5/2, wall-e])
    magnet_holder(h = cap_h-wall, wx=7, wy = 9, md = 5);

    translate([
        cap_display_wx/2 + wall,
        cap_display_wy/2 - wall - 8.5/2,
        wall-e
    ])
    magnet_holder(h = cap_h -cap_display_h -0.4 -wall, wx=7, wy=7, md=5);

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
            r=wall+1,
            rbottom=1.5
        );

        // Inner
        translate([0, 0, cap_display_top_wall+e])
        rcube([cap_display_wx - cap_display_wall*2, cap_display_wy - cap_display_wall*4, cap_display_inner_h], r=0.1);
        // flat cable space
        translate([0, 0, cap_display_top_wall+e])
        rcube([cap_display_wx - cap_display_wall*2 - 8, cap_display_wy - cap_display_wall*4 + 4, cap_display_inner_h], r=0.1);

        // Visible area hole
        translate([0, 0, -2e])
        linear_extrude(
            cap_display_top_wall+2*2e,
            scale = [
                cap_display_view_wx/(cap_display_view_wx + 2*cap_display_top_wall),
                cap_display_view_wy/(cap_display_view_wy + 2*cap_display_top_wall)
            ]
        )
        square([
          // display area + border
          cap_display_view_wx+cap_display_top_wall + 2,
          cap_display_view_wy+cap_display_top_wall + 3
        ], center=true);

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
        translate([0, cap_display_wy/2 - 8.5/2, cap_display_top_wall])
        cylinder(h=cap_display_h, d=5.5);
    }
    
    // Magnet
    translate([0, cap_display_wy/2 - 8.5/2, e])
    difference () {
        translate([0, 0, cap_display_top_wall-e])
        cylinder(h=cap_display_h - cap_display_top_wall, d=7.5);
        translate([0, 0, cap_display_top_wall])
        cylinder(h=cap_display_h, d=5.5);
    }
}

module btn_cap() {
    // Height = (inner_h + wall) - btn_h - space - cap_deepness
    cylinder(tray_h - pcb_h - 2.7 - 0.5 - 0.7, d=4.5);
    cylinder(3, d=7);
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

//mode = 1;

if (!is_undef(mode) && mode == 0) { tray(); }
else if (!is_undef(mode) && mode == 1) { cap1(); }
else if (!is_undef(mode) && mode == 2) { cap2(); }
else if (!is_undef(mode) && mode == 3) { cap_display(); }
else if (!is_undef(mode) && mode == 4) { cable_clip(); }
else if (!is_undef(mode) && mode == 5) { btn_cap(); }
else { all(); }
