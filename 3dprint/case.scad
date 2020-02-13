e = 0.01;
2e = 0.02;

power_with_connector = false;

$fn = 64;
//$fs = 0.15;

wall = 2;

pcb_wx = 145;
pcb_wy = 80;
pcb_h  = 1.6;
pcb_y_margin = 0.2;

tray_inner_wx = pcb_wx - wall - 1;
tray_inner_wy = pcb_wy - wall;
tray_inner_h  = 20;

tray_wx = pcb_wx + wall;
tray_wy = tray_inner_wy + 3*wall;
tray_h  = tray_inner_h + pcb_h + wall;

tray_hinge_ox = 6;
tray_hinge_oz = 7;

cap1_wx = 90;
cap2_wx = tray_wx - cap1_wx;
cap1_slot = 7.3;

cap_inner_h = 18;
cap_h = cap_inner_h + wall;

cap_display_mounts_shift = 0.2;
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
insert_h = 4.2;

latch_z_offset = cap_display_h - 2.0;
latch_neg_x_offset = 27.5;

module qfillet(h, r) {
    difference () {
        translate([-e, -e, 0]) cube([r+e, r+e, h]);
        translate([r, r, -e]) cylinder(h+2e, r = r);
    }
}

module tray_stand_through(h = 10, w = 8, ih = 5, id = 4.0, idt = 2.0) {
    difference() {
        cube_rounded([w, w, h]);
        translate([0, 0, -e]) cylinder(ih+e, d=id);
        translate([0, 0, -e]) cylinder(h+2e, d=idt);
        translate([0, 0, ih-e]) cylinder(id/2+2e, r1=id/2, r2=0);
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
        translate([0, 0, -e]) cylinder(0.1+e, d = 4);
        cylinder(10, d=2);
        translate([0, 0, 0.1-e]) cylinder(h = 2, d1 = 4, d2 = 0);
    }

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

    cylinder(wall - dim, d = 26);

    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);
    rotate([0, 0, 45])
    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);
    rotate([0, 0, 90])
    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);
    rotate([0, 0, 135])
    translate([0, 0, (wall-dim)/2]) cube([50, 2, wall - dim], center = true);


    difference() {
        cylinder(wall - dim, d = 39);
        translate([0, 0, -e])
        cylinder(wall - dim + 2e, d = 35);
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


module _tray_base() {
    difference() {
        cube_rounded([tray_wx, tray_wy, tray_h], r = wall);

        translate([0.5, 0, wall])
        linear_extrude(tray_h)
        square([tray_inner_wx, tray_wy - wall*3], center=true);

        translate([(wall+e)/2, 0, tray_h-pcb_h])
        linear_extrude(pcb_h+e)
        square([tray_wx - wall + e, pcb_wy + 2*pcb_y_margin], center = true);

        // Fan wire slot
        translate([-tray_wx/2 + wall, -pcb_wy/2 + 3,  tray_h-pcb_h-5])
        cube([3, 3, 5]);
    }
}


module tray() {
    difference() {
        union() {
            _tray_base();

            // Hinges area reinforcers
            translate([-tray_wx/2, -tray_wy/2 + wall*1.5 -e, 0])
            cube([tray_hinge_ox*2 + wall*1.5, wall + 2e, tray_h - pcb_h]);

            translate([-tray_wx/2, tray_wy/2 - wall*2.5-e, 0])
            cube([tray_hinge_ox*2 + wall*1.5, wall + 2e, tray_h - pcb_h]);
            
            // Boot0 button guide
            translate([tray_wx/2 - 6, -15, 0])
            cylinder(tray_h - pcb_h - 3, d=6);
            
            // Power input
            if (power_with_connector == false) {
                translate([-40, tray_wy/2-9, 0])
                cube_rounded([20, 18, 4]);
            }
            
            // Back wall
            translate([-tray_wx/2, -tray_wy/2+wall, tray_h-e-0.5])
            cube([wall, tray_wy - 2*wall, cap1_slot]);

        }

        // Hinges space
        translate([-tray_wx/2, -tray_wy/2-e, -e])
        cube([tray_hinge_ox*2 + 0.3, wall + 2e, tray_h+2e]);

        translate([-tray_wx/2, tray_wy/2 - wall - e, -e])
        cube([tray_hinge_ox*2 + 0.3, wall + 2e, tray_h+2e]);

        translate([-tray_wx/2 + tray_hinge_ox, 0, tray_h - tray_hinge_oz])
        rotate([90, 0, 0])
        cylinder(tray_wy + 2e, d = 2, center = true);

            
        // Boot0 button guide hole
        translate([tray_wx/2 - 6, -15, -e])
        cylinder(tray_h, d=3);

        // Power input
        if (power_with_connector == false) {
            translate([-40, tray_wy/2+e, 6])
            rotate([90, 0, 0])
            cube_rounded([5.3, 3.3, 4], r=1.6);
            
            translate([-40-5, tray_wy/2-10, 0]) m2_screw_hole();
            translate([-40+5, tray_wy/2-10, 0]) m2_screw_hole();
        }

        // Trough holes for supports
        translate([tray_wx/2 - 5, -pcb_wy/2 + 3, -e]) cylinder(wall+2e, d=4);
        translate([tray_wx/2 - 5, pcb_wy/2 - 3, -e]) cylinder(wall+2e, d=4);
        translate([tray_wx/2 - 50, -pcb_wy/2 + 3, -e]) cylinder(wall+2e, d=4);
        translate([tray_wx/2 - 50, pcb_wy/2 - 3, -e]) cylinder(wall+2e, d=4);

        // USB
        translate([tray_wx/2-wall, -26, tray_h-pcb_h-2])
        translate([1, 0, 1])
        cube([2+2e, 8, 2+2e], center=true);
        
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
    }

    // PCB support
    difference() {
        translate([-tray_wx/2 + 3 + wall, 0, -e])
        cube_rounded([7, 7, tray_h-pcb_h], r=1);
        translate([-tray_wx/2 + 3 + wall, 0, tray_h - pcb_h - insert_h])
        cylinder(insert_h+e, d=insert_d);
    }


    // PCB + Display supports
    translate([tray_wx/2 - 5, -pcb_wy/2 + 3, 0])
    tray_stand_through(h = tray_h-pcb_h, w=8, id=4, ih=tray_h-pcb_h-4);

    translate([tray_wx/2 - 5, pcb_wy/2 - 3, 0])
    tray_stand_through(h = tray_h-pcb_h, w=8, id=4, ih=tray_h-pcb_h-4);

    translate([tray_wx/2 - 50, -pcb_wy/2 + 3, 0])
    tray_stand_through(h = tray_h-pcb_h, w=8, id=4, ih=tray_h-pcb_h-4);

    translate([tray_wx/2 - 50, pcb_wy/2 - 3, 0])
    tray_stand_through(h = tray_h-pcb_h, w=8, id=4, ih=tray_h-pcb_h-4);
    
    // Fan wire latches
    translate([5, -tray_wy/2+wall+2, 0])
    cube([10, 1, 12]);
    translate([-55, -tray_wy/2+wall+2, 0])
    cube([10, 1, 12]);
}


module cap1() {
    diag = 14;

    difference() {
        union() {
            translate([0, -tray_wy/2, 0])
            cube([cap1_wx, tray_wy, cap_h]);

            // Tray hinges parts
            translate([0, -tray_wy/2, 0])
            cube([tray_hinge_ox*2, wall, cap_h + tray_hinge_oz + tray_hinge_ox]);

            translate([0, tray_wy/2 - wall, 0])
            cube([tray_hinge_ox*2, wall, cap_h + tray_hinge_oz + tray_hinge_ox]);
        }

        rotate([0, 45, 0]) cube([diag, tray_wy+2e, diag], center = true);

        // Tray hinges rounding
        translate([0, -tray_wy/2-e, cap_h + tray_hinge_oz + tray_hinge_ox])
        rotate([-90, 0, 0])
        qfillet(tray_wy+2e, tray_hinge_ox);

        translate([tray_hinge_ox*2, tray_wy/2+e, cap_h + tray_hinge_oz + tray_hinge_ox])
        rotate([90, 180, 0])
        qfillet(tray_wy+2e, tray_hinge_ox);

        // Tray hinges hole
        translate([tray_hinge_ox, tray_wy/2, cap_h + tray_hinge_oz])
        rotate([90, 0, 0])
        m2_screw_hole();

        translate([tray_hinge_ox, -tray_wy/2, cap_h + tray_hinge_oz])
        rotate([-90, 0, 0])
        m2_screw_hole();

        // Remove inner
        translate([wall, -tray_wy/2 + wall, wall])
        difference() {
            cube([cap1_wx, tray_wy - 2*wall, cap_h - wall + e], center = false);
            rotate([0, 45, 0]) translate([0, tray_wy/2, 0]) cube([diag, tray_wy+2e, diag], center = true);
        }

        translate([-e, -tray_wy/2 + wall, cap_h - cap1_slot])
        cube([wall+2e, tray_wy - 2*wall, cap1_slot+e]);

        translate([cap1_wx, tray_wy/2+e, cap_h])
        rotate([90, 180, 0])
        qfillet(tray_wy+2e, cap_inner_h/2);

        // Cap2 hinges hole
        translate([cap1_wx - cap_inner_h/2, tray_wy/2, cap_h - cap_inner_h/2])
        rotate([90, 0, 0])
        m2_screw_hole();

        translate([cap1_wx - cap_inner_h/2, -tray_wy/2, cap_h - cap_inner_h/2])
        rotate([-90, 0, 0])
        m2_screw_hole();

        // Round corners
        translate([0, -tray_wy/2, -e])
        qfillet(cap_h + tray_hinge_oz + tray_hinge_ox + 2e, wall);

        translate([0, tray_wy/2, -e])
        rotate([0, 0, -90])
        qfillet(cap_h + tray_hinge_oz + tray_hinge_ox + 2e, wall);
    }
    
    // Fan wire latches
    translate([15, tray_wy/2-wall-2, 0])
    cube([10, 1, cap_h-4]);
    translate([35, tray_wy/2-wall-2, 0])
    cube([10, 1, cap_h-4]);
    translate([55, tray_wy/2-wall-2, 0])
    cube([10, 1, cap_h-4]);

}


module cap2() {
    difference() {
        translate([0, -tray_wy/2, 0])
        cube([cap2_wx, tray_wy, cap_h]);

        // Roundings
        translate([0, -tray_wy/2, -e])
        qfillet(cap_h + 2e, wall);

        translate([0, tray_wy/2, -e])
        rotate([0, 0, -90])
        qfillet(cap_h + 2e, wall);

        // Inner
        translate([wall, -tray_wy/2 + wall, wall])
        cube_rounded([cap2_wx + 2*wall, tray_wy - 2*wall, cap_h], center=false, r=wall);

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

        // Inserts
        translate([-cap_display_x_inserts_space/2, -pcb_wy/2 + 3, cap_display_h + e - insert_h])
        cylinder(insert_h, d=insert_d);

        translate([-cap_display_x_inserts_space/2, pcb_wy/2 - 3, cap_display_h + e - insert_h])
        cylinder(insert_h, d=insert_d);

        translate([cap_display_x_inserts_space/2, -pcb_wy/2 + 3, cap_display_h + e - insert_h])
        cylinder(insert_h, d=insert_d);

        translate([cap_display_x_inserts_space/2, pcb_wy/2 - 3, cap_display_h + e - insert_h])
        cylinder(insert_h, d=insert_d);

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
        translate([-5, -e, 0]) cylinder(5, 2);
        translate([5, -e, 0]) cylinder(5, 2);
    }
}

module all() {
    translate([tray_wx/2, 0, 0])
    tray();

    //translate([-9.0, 0, -7])
    translate([-60, 0, -7])
    rotate([180, -135, 0])
    cap1();

    translate([-70, 0, 150])
    rotate([0, 135, 0])
    cap2();

    translate([120, 100, 0])
    cap_display();

    translate([30, 80, 0])
    cable_clip();
}

//mode = 2;

if (!is_undef(mode) && mode == 0) { tray(); }
else if (!is_undef(mode) && mode == 1) { cap1(); }
else if (!is_undef(mode) && mode == 2) { cap2(); }
else if (!is_undef(mode) && mode == 3) { cap_display(); }
else if (!is_undef(mode) && mode == 4) { cable_clip(); }
else { all(); }
