e = 0.01;
2e = 0.02;

power_with_connector = false;

$fn = 64;
//$fs = 0.15;

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
tray_inner_h  = 20;

tray_wx = pcb_wx + hinges_wall;
tray_wy = tray_inner_wy + 3*wall;
tray_h  = tray_inner_h + pcb_h + wall;

cap1_wx = 93;
cap2_wx = tray_wx - cap1_wx;

cap_inner_h = 19;
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

insert_d = 3.5;
insert_h = 3.2;

latch_z_offset = cap_display_h - 2.0;
latch_neg_x_offset = 27.5;

module qfillet(h, r) {
    difference () {
        translate([-e, -e, 0]) cube([r+e, r+e, h]);
        translate([r, r, -e]) cylinder(h+2e, r = r);
    }
}

module cube_rounded(size = [10, 10, 10], center = true, r = 1) {
    x = size[0]; y = size[1]; h = size[2];

    tx = center ? -x/2 : 0;
    ty = center ? -y/2 : 0;

    translate([tx, ty, 0])
    difference() {
        cube(size);
        translate([0, 0, -e]) qfillet(h+2e, r);
        translate([x, 0, -e]) rotate([0, 0, 90]) qfillet(h+2e, r);
        translate([x, y, -e]) rotate([0, 0, 180]) qfillet(h+2e, r);
        translate([0, y, -e]) rotate([0, 0, 270]) qfillet(h+2e, r);
    }
}

module m2_screw_hole() {
    translate([0, 0, -e]) {
        cylinder(10, d=2.2);
        translate([0, 0, 0.1-e]) cylinder(h = 2, d1 = 4, d2 = 0);
        // Make head outer part long for deep holes
        translate([0, 0, 0.1]) mirror([0, 0, 1]) cylinder(30, d = 4);
    }

}

module fan50_guides() {
    translate([20, 20, e]) cylinder(wall+2, d=5.6);
    translate([20, -20, e]) cylinder(wall+2, d=5.6);
    translate([-20, 20, e]) cylinder(wall+2, d=5.6);
    translate([-20, -20, e]) cylinder(wall+2, d=5.6);
}


module fan50_hole() {
    translate([20, 20, 0]) m2_screw_hole();
    translate([20, -20, 0]) m2_screw_hole();
    translate([-20, 20, 0]) m2_screw_hole();
    translate([-20, -20, 0]) m2_screw_hole();
    translate([0, 0, -e]) cylinder(wall+2e, d = 48);
}

module fan50_grill() {
    dim = 0.5;

    cylinder(wall - dim, d = 24);

    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);
    rotate([0, 0, 45])
    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);
    rotate([0, 0, 90])
    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);
    rotate([0, 0, 135])
    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);


    difference() {
        cylinder(wall - dim, d = 38);
        translate([0, 0, -e])
        cylinder(wall - dim + 2e, d = 34);
    };
}

module latch(l = 10) {
    rotate([0, 90, 0])
    translate([0, 0, -l/2])
    linear_extrude(l)
    polygon([
        [-1, 0],
        [-0.5, 0.5],
        [0.5, 0.5],
        [1, 0],
        [1, -0.5],
        [-1, -0.5]
    ]);
}

module hinges_add(second = false) {
    rotate([-90, 0, 0])
    mirror([0, 0, second == false ? 0 : 1])
    translate([0, 0, hinges_margin])
    linear_extrude(hinges_section_w*2)
    union() {
        circle(hinges_r);
        polygon([
            [0, 0],
            [-hinges_r/sqrt(2), hinges_r/sqrt(2)],
            [0, hinges_r*sqrt(2)],
            [hinges_r, hinges_r*sqrt(2)],
            [hinges_r, 0]
        ]);
    }
}

module hinges_substract(second = false) {
    rotate([-90, 0, 0])
    mirror([0, 0, second == false ? 0 : 1]) {
        // through hole
        cylinder(hinges_len, d = hinges_id);
        // screw head space
        translate([0, 0, -e])
        cylinder(hinges_margin+2e, d = 5.5);
        // screw nut space
        translate([0, 0, hinges_len - hinges_margin_tail - e])
        cylinder(hinges_margin_tail, d = 5.5);
        // hinge space
        translate([0, 0, second == false ? hinges_margin + hinges_section_w : hinges_margin - hinges_gap])
        cylinder(hinges_section_w + hinges_gap, r = hinges_r + hinges_gap);
    }
}

module tray_pcb_support() {
    difference() {
        cube_rounded([7, 7, tray_h-pcb_h], r=1);

        translate([0, 0, tray_h - pcb_h + e])
        mirror([0, 0, 1])
        union() {
            cylinder(insert_h, d = insert_d);
            cylinder(insert_h+10, d = 2.5);
        }

    }
}

module wire_latch() {
    rotate([0, 90, 0])
    linear_extrude(10)
    polygon([
        [0, 0],
        [-14, 0],
        [-14, 1],
        [-13, 1.7],
        [-12, 1],
        [0, 1]
    ]);
}


module _tray_base() {
    difference() {
        cube_rounded([tray_wx, tray_wy, tray_h], r = wall);

        translate([-(tray_wx-tray_inner_wx)/2 + hinges_wall + 1, 0, wall])
        linear_extrude(tray_h)
        square([tray_inner_wx, tray_wy - wall*3], center=true);

        translate([tray_wx - wall/2 - pcb_wx, 0, tray_h-pcb_h])
        linear_extrude(pcb_h+e)
        square([tray_wx - wall + e + pcb_x_margin*2, pcb_wy + 2*pcb_y_margin], center = true);
    }
}


module tray() {
    difference() {
        union() {
            _tray_base();

            // PCB + Display supports (solid, no holes)
            translate([tray_wx/2 - 5, -pcb_wy/2 + 3, 0])
            cube_rounded([8, 8, tray_h-pcb_h - e]);

            translate([tray_wx/2 - 5, pcb_wy/2 - 3, 0])
            cube_rounded([8, 8, tray_h-pcb_h - e]);

            translate([tray_wx/2 - 50, -pcb_wy/2 + 3, 0])
            cube_rounded([8, 8, tray_h-pcb_h - e]);

            translate([tray_wx/2 - 50, pcb_wy/2 - 3, 0])
            cube_rounded([8, 8, tray_h-pcb_h - e]);

            // Boot0 button guide
            // Height = inner - btn_height - space_0.5_mm - cap_2_mm
            translate([tray_wx/2 - 6, -17, 0])
            cylinder(tray_h - pcb_h - 2.5 - 0.5 - 2.0, d=7);

            // Power input
            if (power_with_connector == false) {
                translate([-40, tray_wy/2-9, 0])
                cube_rounded([20, 18, 4]);
            }

            // Hinges addons
            translate([-tray_wx/2, -tray_wy/2, tray_h])
            hinges_add(second = false);

            translate([-tray_wx/2, tray_wy/2, tray_h])
            hinges_add(second = true);

            // Hinge angle limiter
            translate([-tray_wx/2, 0, tray_h - hinges_r])
            rotate([90, 45, 0])
            cube([hinges_r*sqrt(2), hinges_r*sqrt(2), tray_wy - 2*hinges_len], center=true);
        }

        // Fan wire slot
        translate([-tray_wx/2 + hinges_wall, -pcb_wy/2,  tray_h-pcb_h-3+e])
        cube([3, 2.6, 5]);

        // Boot0 button guide hole
        translate([tray_wx/2 - 6, -17, -e])
        cylinder(tray_h, d=5);

        // Power input
        if (power_with_connector == false) {
            translate([-40, tray_wy/2+e, 6])
            rotate([90, 0, 0])
            cube_rounded([5.3, 3.3, 4], r=1.6);

            translate([-40-5, tray_wy/2-10, 0]) m2_screw_hole();
            translate([-40+5, tray_wy/2-10, 0]) m2_screw_hole();
        }

        // Holes in supports for 14mm M2 screws (with 3mm display cap inserts)
        translate([tray_wx/2 - 5, -pcb_wy/2 + 3, tray_h - (14-3)]) m2_screw_hole();
        translate([tray_wx/2 - 5, pcb_wy/2 - 3, tray_h - (14-3)]) m2_screw_hole();
        translate([tray_wx/2 - 50, -pcb_wy/2 + 3, tray_h - (14-3)]) m2_screw_hole();
        translate([tray_wx/2 - 50, pcb_wy/2 - 3, tray_h - (14-3)]) m2_screw_hole();

        // USB trough
        translate([tray_wx/2, 12, tray_h-pcb_h])
        translate([-wall/2, 0, -(2.7/2)+e])
        cube([wall+2e, 8, 2.7+e], center=true);

        // USB blind
        translate([tray_wx/2-wall+0.8, 26, tray_h-pcb_h])
        translate([-wall/2, 0, -(2.7/2)+e])
        cube([wall+2e, 8, 2.7+e], center=true);

        // Power Switch
        translate([-10, tray_wy/2+e, 9])
        rotate([90, 0, 0])
        union() {
            linear_extrude(5)
            square([18.8, 13.4], center=true);
            linear_extrude(5)
            polygon([[10, 3], [9.4, 3.5], [-9.4, 3.5], [-10, 3],
                     [-10, -3], [-9.4, -3.5], [9.4, -3.5], [10, -3]]);
            translate([0, 0, 2])
            linear_extrude(3)
            polygon([[11, 3], [9.4, 4.5], [-9.4, 4.5], [-11, 3],
                     [-11, -3], [-9.4, -4.5], [9.4, -4.5], [11, -3]]);
        }

        // Hinges groves
        translate([-tray_wx/2, -tray_wy/2, tray_h])
        hinges_substract(second = false);

        translate([-tray_wx/2, tray_wy/2, tray_h])
        hinges_substract(second = true);
    }

    // PCB supports
    translate([tray_wx/2 - pcb_wx + 10, -pcb_wy/2 + 3, e])
    tray_pcb_support();

    mirror([0, 1, 0])
    translate([tray_wx/2 - pcb_wx + 10, -pcb_wy/2 + 3, e])
    tray_pcb_support();


    // Fan wire latches
    translate([3, -tray_wy/2+wall+3, 0])
    mirror([0, 1, 0]) wire_latch();
    translate([-50, -tray_wy/2+wall+3, 0])
    mirror([0, 1, 0]) wire_latch();
}


module cap1() {
    diag = 14;

    difference() {
        union() {
            translate([0, -tray_wy/2, 0])
            cube([cap1_wx, tray_wy, cap_h]);

            // Hinges addons
            translate([0, -tray_wy/2, cap_h])
            hinges_add(second = false);

            translate([0, tray_wy/2, cap_h])
            hinges_add(second = true);
        }

        // Fan wire slot
        translate([hinges_wall, pcb_wy/2,  cap_h-5+e])
        mirror([0, 1, 0]) cube([3, 2.6, 5]);

        // Remove inner
        translate([hinges_wall + 0.5, -tray_wy/2 + wall, wall])
        cube([cap1_wx, tray_wy - 2*wall, cap_h - wall + e], center = false);

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

        // Round corners
        translate([0, -tray_wy/2, -e])
        qfillet(cap_h + 2e, wall);

        translate([0, tray_wy/2, -e])
        rotate([0, 0, -90])
        qfillet(cap_h + 2e, wall);

        // Hinges groves
        translate([0, -tray_wy/2, cap_h])
        hinges_substract(second = false);

        translate([0, tray_wy/2, cap_h])
        hinges_substract(second = true);
    }

    // Fan wire latches
    translate([15, tray_wy/2-wall-2, 0]) wire_latch();
    translate([35, tray_wy/2-wall-2, 0]) wire_latch();
    translate([55, tray_wy/2-wall-2, 0]) wire_latch();
}


module cap2() {
    difference() {
        union() {
            difference() {
                translate([0, -tray_wy/2, 0])
                cube([cap2_wx, tray_wy, cap_h]);

                // Inner
                translate([wall, -tray_wy/2 + wall, wall])
                cube_rounded([cap2_wx + 2*wall, tray_wy - 2*wall, cap_h], center=false, r=wall);
            }

            // Fans screws guildes/reinforcers
            translate([3+25, 0, 0]) fan50_guides();
        }

        // Roundings
        translate([0, -tray_wy/2, -e])
        qfillet(cap_h + 2e, wall);

        translate([0, tray_wy/2, -e])
        rotate([0, 0, -90])
        qfillet(cap_h + 2e, wall);

        // Fan screws holes
        translate([3+25, 0, 0]) fan50_hole();

        // Small gap for hinges
        translate([cap2_wx-0.2, -tray_wy/2-e, wall])
        cube([wall, tray_wy+2e, cap_h]);

        // Opening helper
        translate([-e, 7.5, 4])
        rotate([90, 90, 0])
        linear_extrude(15)
        polygon([[-1.5, 0], [1.5, 0], [0.5, 1], [-0.5, 1]]);
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

    // Latches
    translate([latch_neg_x_offset, -tray_wy/2 + wall, cap_h - latch_z_offset])
    latch(10);

    translate([latch_neg_x_offset, tray_wy/2 - wall, cap_h - latch_z_offset])
    rotate([180, 0, 0])
    latch(10);
}

module _cap_display_insert_hole() {
    translate([0, 0, cap_display_h + e])
    mirror([0, 0, 1])
    union() {
        cylinder(insert_h, d = insert_d);
        cylinder(insert_h+0.8, d = 2.5);
    }
}

module cap_display() {
    difference() {
        cube_rounded([cap_display_wx, cap_display_wy, cap_display_h], r=wall);

        translate([0, 0, cap_display_top_wall+e])
        cube_rounded([cap_display_wx - cap_display_wall*2, cap_display_wy - cap_display_wall*4, cap_display_inner_h], r=wall);

        // Visible area hole
        translate([0, 0, -2e])
        linear_extrude(
            cap_display_top_wall+2*2e,
            scale = [
                cap_display_view_wx/(cap_display_view_wx + 2*cap_display_top_wall),
                cap_display_view_wy/(cap_display_view_wy + 2*cap_display_top_wall)
            ]
        )
        square([cap_display_view_wx+cap_display_top_wall, cap_display_view_wy+cap_display_top_wall], center=true);

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

        // Latches
        translate([0, -tray_wy/2 + wall, cap_display_h - latch_z_offset])
        latch(20);

        translate([0, tray_wy/2 - wall, cap_display_h - latch_z_offset])
        rotate([180, 0, 0])
        latch(20);
    }
}

module cable_clip() {
    difference() {
        cube_rounded([20, 10, 4], r=3);
        translate([-5, 0, -e]) cylinder(5, d=2);
        translate([5, 0, -e]) cylinder(5, d=2);
    }
}

module btn_cap() {
    // Height = inner_h + wall - btn_h - cap_base - space - cap_deepness
    cylinder(tray_h - pcb_h - 2.5 - 2.0 - 0.5 - 1, d=4.5);
    cylinder(2, d=7);
}

module all() {
    translate([tray_wx/2, 0, 0])
    tray();

    translate([-40, 0, 8])
    rotate([180, -135, 0])
    cap1();

    translate([-50, 0, 160])
    rotate([0, 135, 0])
    cap2();

    translate([120, 100, 0])
    cap_display();

    translate([30, 80, 0])
    cable_clip();

    translate([165, -17, 0])
    btn_cap();
}

mode = 0;

if (!is_undef(mode) && mode == 0) { tray(); }
else if (!is_undef(mode) && mode == 1) { cap1(); }
else if (!is_undef(mode) && mode == 2) { cap2(); }
else if (!is_undef(mode) && mode == 3) { cap_display(); }
else if (!is_undef(mode) && mode == 4) { cable_clip(); }
else if (!is_undef(mode) && mode == 5) { btn_cap(); }
else { all(); }
