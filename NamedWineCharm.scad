
name="ine carm";

fontSize=8;
bottomPlateHeight = 12; // normalize nameplate to that size in order to get a fixed height regardless of characters used in font
font="Vivaldi:style=Italic";
innerRadius=6;
bottomplatethickness=2;
fontthickness=2;
textMargin = 3;
ringThickness = 2;
openCutWidth=8;

// figure out the bounding rectangle of the text, which depends on font, font size and margin
// taken approach/idea/code from https://mastering-openscad.eu/buch/example_06/ 
// - basically project the text on to x axis to get width (and take hull to not get a 
// collection of rectangles) then project on to y axis to get height
module text_area(output) {

    estimated_length = len(output) * fontSize * 2;
    
    resize([0,bottomPlateHeight,0], auto=[false, true, false])
    projection()
    intersection(){
        translate( [0,0,-1] )
        rotate([-90,0,0])
        translate([0,0,-(3 * fontSize) / 2])
        linear_extrude( height = 3 * fontSize )
        hull()
        projection()
        rotate([90,0,0])
        linear_extrude( height = 1)
        text(
            text = output, 
            size = fontSize, 
            font = font, 
            valign = "center", 
            halign = "center",
            $fn = 50
        );

        rotate( [0, -90, 0] )
        translate( [0, 0, -estimated_length/2] )
        linear_extrude( height = estimated_length )
        hull()
        projection()    
        rotate( [0, 90, 0] )
        linear_extrude( height = 1 )
        text(
            text = output, 
            size = fontSize, 
            font = font, 
            valign = "center", 
            halign = "center",
            $fn = 50
        );
    }
}

// plate to write the name on
linear_extrude( height = bottomplatethickness )
    offset( delta = textMargin )
        text_area(name);

// write the name
translate([0, 0,bottomplatethickness]) 
    linear_extrude(height = fontthickness)
        text(
            text = name, 
            size = fontSize, 
            font = font, 
            valign = "center", 
            halign = "center",
            $fn = 50
        );


// add the glass attachment ring
cutCylRad = (innerRadius+ringThickness) * tan(asin(openCutWidth/(2*innerRadius)));

translate([0, bottomPlateHeight / 2 + innerRadius + textMargin, 0])
difference()
{
	difference()
	{
		cylinder(r=innerRadius+ringThickness, h=bottomplatethickness);
		cylinder(r=innerRadius, h=bottomplatethickness);
	}
	translate([0, innerRadius+ringThickness, ringThickness/2]) 
        rotate([90,0,0]) 
            cylinder(innerRadius+ringThickness, cutCylRad, 0); 
}
