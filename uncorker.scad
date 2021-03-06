include <libraries/relativity.scad/relativity.scad>;
use <libraries/publicDomainGearV1.1.scad>;

module rod_rack(mm_per_tooth=9, height=10, inner_radius=12, anchor=$inward, orientation=top) {
	assign(pi = 3.1415926)
	assign(rack_height = 2 * mm_per_tooth / pi + inner_radius)
	assign(rack_y_offset = mm_per_tooth / pi + inner_radius)
	assign(number_of_teeth = floor(height / mm_per_tooth - 1/2)) // mm_per_tooth * number_of_teeth + mm_per_tooth * 1/2 = height
	assign(rack_length = mm_per_tooth * (number_of_teeth + 1/2))
	assign(rack_x_offset = mm_per_tooth * 3 / 4 + (height - rack_length) / 2) {
		echo(str("rh=", rack_height, ", y=", rack_y_offset, ", x=", rack_x_offset, ", n=", number_of_teeth));
		rotate_extrude()
		rotated([0, 0, 90])
		translated([rack_x_offset, rack_y_offset, 0])
		rack_outline(mm_per_tooth=mm_per_tooth, number_of_teeth=number_of_teeth, height=rack_height);

		rod(r=inner_radius, h=height, anchor=bottom);
		//children();
	}
	_rod(r=inner_radius, h=height, anchor=bottom)
	children();
}

module cone(r1, r2=false, h) {
	r2 = r2 != false ? r2 : r1;
	if (_has_token($class, $show))
	cylinder(r1=r1, r2=r2, h=h);
	_rod(r=r1, h=h, anchor=bottom)
	children();
}

// Uncorker rod rack radius, height, mm_per_tooth
uc_rrr = 10;
uc_rrh = 100;
uc_mm_per_tooth = 9;
// Uncorker handle shaft width, height, length
uc_hsw = 14;
uc_hsh = 40;
uc_hsl = 14;
// Uncorker handle circle radius, height, y offset, wall thickness
uc_hcr = 20;
uc_hch = uc_hsw;
uc_hcy = -4;
uc_hcwall = 4;

module uncorker_handle() {
	differed("+", "-") {
		cone(r1=uc_rrr, r2=uc_hsw / 2, h=uc_hsh * 3/4, $class="+")
		align(bottom)
		box([uc_hsl, uc_hsw, uc_hsh], anchor=bottom, $class="+")
		align(top)
		translated([0, 0, uc_hcy])
		rod(r=uc_hcr, h=uc_hch, orientation=y, $class="+")
		rod(r=$parent_size.x / 2 - uc_hcwall, h=$parent_size.z, orientation=y, $class="-");
	}
	_box([2 * uc_hcr, uc_hsw, uc_hsh + uc_hcy + 2 * uc_hcr], anchor=bottom)
	children();
}

module uncorker_body() {
	differed("+", "-")
	hulled("h", $class="-")
	hulled("H", $class="+") {
		rod(r=10, h=10, anchor=bottom, $class="H +")
		assign(base_height = $parent_size.z)
		assign(base_radius = $parent_size.x / 2)
		align(top)
		box([12, 5, 5], anchor=bottom, $class="H +")
		align(bottom)
		box([$parent_size.x, $parent_size.y, 40], anchor=bottom, $class="+")
		align(top)
		assign(shaft_height = $parent_size.z)
		rod(r=min($parent_size.x, $parent_size.y) / 2 - 1, h=$parent_size.z + 10, anchor=top, $class="-")
		assign(overhang = $parent_size.z - shaft_height)
		align(bottom)
		#rod(r=$parent_size.x / 2, h=overhang, anchor=top, $class="-")
		align(bottom)
		rod(r=$parent_size.x / 2, h=base_height + $parent_size.z, anchor=bottom, $class="h -")
		align(bottom)
		rod(r=base_radius - 2, h=base_height - 2 + overhang, anchor=bottom, $class="h -");

		ball(1, $class="H +");
	}
}

difference() {
	uncorker_body();
	box([100, 100, 100], anchor=[-1, 0, 0]);
}


*rod_rack(mm_per_tooth=uc_mm_per_tooth, height=uc_rrh, inner_radius=uc_rrr)
align(top)
uncorker_handle();

*rod_rack(mm_per_tooth=9, height=100, inner_radius=10)
align(bottom)
%rod(size=hammard($parent_size, [1,1,1]), anchor=bottom);
